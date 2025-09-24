import 'package:ut_report_generator/blocs/slide_bloc.dart';
import 'package:ut_report_generator/models/response/edit_pivot_table_response.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/charting_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/selection_mode.dart';
import 'package:ut_report_generator/models/pivot_table/data_filter/self.dart';
import 'package:ut_report_generator/models/pivot_table/pivot_table_level.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/api/pivot_table/self.dart' as pivot_table;
import 'package:ut_report_generator/api/pivot_table/filter/self.dart'
    as filter_api;
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';
import 'package:ut_report_generator/utils/copy_with_replacement.dart';
import 'package:ut_report_generator/utils/copy_without.dart';

class PivotTableBloc extends SlideBloc<PivotTable> {
  PivotTableBloc({
    required super.report,
    required super.initialSlide,
    required super.setSlide,
  });

  void _updateAfterEdition(EditPivotTable_Response response) {
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        data: response.data,
        filters: response.filters,
        preview: response.preview,
      ),
    );
  }

  Future<void> onFileRemoved(String file) async {
    // @todo
    // route missing
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        source: pivotTable.source.copyWith(
          files: copyWithout(pivotTable.source.files, file),
        ),
      ),
    );

    await pivot_table
        .removeFile(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          fileName: file,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onFileAdded(String file) async {
    if (this.initialSlide.source.files.contains(file)) {
      // Very naïve duplication checking that I'm not really sure I need
      return;
    }

    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        source: pivotTable.source.copyWith(
          files: copyWithAdded(pivotTable.source.files, file),
        ),
      ),
    );

    await pivot_table
        .addFile(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          fileName: file,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onOptionAdded(String option, int filterIndex) async {
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          pivotTable.filters,
          filterIndex,
          (filter) => filter.copyWith(
            selectedValues: copyWithAdded(filter.selectedValues, option),
          ),
        ),
      ),
    );

    await filter_api
        .addOptionToFilter(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          filter: filterIndex,
          option: option,
        )
        .then(_updateAfterEdition);
  }

  // This function should handle invalid deletion cases. That is, when the
  // option is the last one in the filter, the user shouldn't be allowed to delete
  // it
  Future<void> onOptionRemoved(String option, int filterIndex) async {
    if (this.initialSlide.filters[filterIndex].selectedValues.length == 1) {
      return;
    }

    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          pivotTable.filters,
          filterIndex,
          (filter) => filter.copyWith(
            selectedValues: copyWithout(filter.selectedValues, option),
          ),
        ),
      ),
    );

    await filter_api
        .removeOptionFromFilter(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          filter: filterIndex,
          option: option,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onOptionSwitched(String option, int filterIndex) async {
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          pivotTable.filters,
          filterIndex,
          (filter) => filter.copyWith(selectedValues: [option]),
        ),
      ),
    );

    await filter_api
        .switchOptionInFilter(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          filter: filterIndex,
          option: option,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onFilterDeleted(int filterIndex) async {
    Future<void> Function() callback = () async {};

    if (this.initialSlide.filters[filterIndex].chartingMode ==
        ChartingMode.chart) {
      if (this.initialSlide.filters.length == 1) {
        return;
      }

      var newChartIndex = this.initialSlide.filters.indexWhere(
        (filter) => filter.chartingMode == ChartingMode.none,
      );
      if (newChartIndex == -1) {
        newChartIndex = this.initialSlide.filters.indexWhere(
          (filter) => filter.chartingMode != ChartingMode.chart,
        );
      }

      callback = () => setChart(newChartIndex);
    }

    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithout(
          pivotTable.filters,
          pivotTable.filters[filterIndex],
        ),
      ),
    );

    await callback()
        .then(
          (_) => filter_api.deleteFilter(
            report: this.report,
            pivotTable: this.initialSlide.identifier,
            filter: filterIndex,
          ),
        )
        .then(_updateAfterEdition);
  }

  Future<void> onFiltersReordered(int oldIndex, int newIndex) async {
    this.setSlide((pivotTable) {
      var filters = [...pivotTable.filters];
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      var filter = filters.removeAt(oldIndex);
      filters.insert(newIndex, filter);
      return pivotTable.copyWith(filters: filters);
    });

    await pivot_table.reorderFilter(
      report: this.report,
      pivotTable: this.initialSlide.identifier,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  Future<void> toggleSelectionMode(int filterIndex) async {
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          this.initialSlide.filters,
          filterIndex,
          (filter) => filter.copyWith(
            selectionMode:
                filter.selectionMode == SelectionMode.many
                    ? SelectionMode.one
                    : SelectionMode.many,
            selectedValues:
                filter.selectionMode == SelectionMode.many
                    ? filter.selectedValues.isNotEmpty
                        ? [filter.selectedValues[0]]
                        : []
                    : filter.selectedValues,
          ),
        ),
      ),
    );

    // @todo Also, create an API for this
    await filter_api
        .toggleSelectionMode(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          filter: filterIndex,
        )
        .then(_updateAfterEdition);
  }

  Future<void> swapChartingModes(
    int firstFilterIndex,
    int secondFilterIndex,
  ) async {
    var chartIndex = firstFilterIndex;
    var superChartIndex = secondFilterIndex;

    this.setSlide((pivotTable) {
      final firstFilterMode = pivotTable.filters[firstFilterIndex].chartingMode;
      final secondFilterMode =
          pivotTable.filters[secondFilterIndex].chartingMode;

      if (secondFilterMode == ChartingMode.chart) {
        chartIndex = secondFilterIndex;
        superChartIndex = firstFilterIndex;
      }

      var filters = copyWithReplacement(
        pivotTable.filters,
        firstFilterIndex,
        (filter) => filter.copyWith(chartingMode: secondFilterMode),
      );
      filters = copyWithReplacement(
        filters,
        secondFilterIndex,
        (filter) => filter.copyWith(chartingMode: firstFilterMode),
      );

      return this.initialSlide.copyWith(filters: filters);
    });

    pivot_table
        .setCharts(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          chart: superChartIndex,
          superChart: chartIndex,
        )
        .then((data) {
          this.setSlide((pivotTable) => pivotTable.copyWith(data: data));
        });
  }

  // Makes the filter at `filterIndex` be of charting mode `chart`; the super chart,
  // if other than the filter edited, is left untouched and all other filters
  // acquire the charting mode `none`
  Future<void> setChart(int filterIndex) async {
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters:
            pivotTable.filters.indexed.map((data) {
              final (index, filter) = data;
              if (filterIndex == index) {
                return filter.copyWith(chartingMode: ChartingMode.chart);
              }
              if (filter.chartingMode == ChartingMode.superChart) {
                return filter;
              }
              return filter.copyWith(chartingMode: ChartingMode.none);
            }).toList(),
      ),
    );

    await pivot_table
        .setCharts(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          chart: filterIndex,
        )
        .then((data) {
          this.setSlide((pivotTable) => pivotTable.copyWith(data: data));
        });
  }

  Future<void> setSuperChart(int filterIndex) async {
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters:
            pivotTable.filters.indexed.map((data) {
              var (index, filter) = data;
              if (index == filterIndex) {
                return filter.copyWith(chartingMode: ChartingMode.superChart);
              }
              if (filter.chartingMode == ChartingMode.chart) {
                return filter;
              }
              return filter.copyWith(chartingMode: ChartingMode.none);
            }).toList(),
      ),
    );

    await pivot_table
        .setCharts(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          superChart: filterIndex,
        )
        .then((data) {
          this.setSlide((pivotTable) => pivotTable.copyWith(data: data));
        });
  }

  Future<void> unsetSuperChart() async {
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters:
            pivotTable.filters.indexed.map((data) {
              final (index, filter) = data;
              if (filter.chartingMode == ChartingMode.chart) {
                return filter;
              }
              return filter.copyWith(chartingMode: ChartingMode.none);
            }).toList(),
      ),
    );

    await pivot_table
        .setCharts(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          superChart: -1,
        )
        .then((data) {
          this.setSlide((pivotTable) => pivotTable.copyWith(data: data));
        });
  }

  Future<void> onFilterSelected(PivotTableLevel level) async {
    this.setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithAdded(
          pivotTable.filters,
          DataFilter(
            level: level,
            selectedValues: [],
            possibleValues: [],
            // This has to match the default mode in the backend
            // in order to improve UI consistency
            selectionMode: SelectionMode.many,
            chartingMode: ChartingMode.none,
          ),
        ),
      ),
    );
    filter_api
        .createDataFilter(
          report: this.report,
          pivotTable: this.initialSlide.identifier,
          level: level,
        )
        .then((newFilter) {
          this.setSlide(
            (pivotTable) => pivotTable.copyWith(
              filters:
                  pivotTable.filters
                      .map(
                        (filter) => filter.level == level ? newFilter : filter,
                      )
                      .toList(),
            ),
          );
        });
  }
}
