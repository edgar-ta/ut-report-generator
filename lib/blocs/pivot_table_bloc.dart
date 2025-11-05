import 'package:ut_report_generator/blocs/slide_bloc.dart';
import 'package:ut_report_generator/models/pivot_table/aggregate_function_type.dart';
import 'package:ut_report_generator/models/pivot_table/filter_function_type.dart';
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
    required super.slideshow,
    required super.initialSlide,
    required super.setSlide,
  });

  void _updateAfterEdition(EditPivotTableResponse response) {
    setSlide(
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
    setSlide(
      (pivotTable) => pivotTable.copyWith(
        source: pivotTable.source.copyWith(
          files: copyWithout(pivotTable.source.files, file),
        ),
      ),
    );

    await pivot_table
        .removeFile(
          report: slideshow,
          pivotTable: initialSlide.identifier,
          fileName: file,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onFileAdded(String file) async {
    if (initialSlide.source.files.contains(file)) {
      // Very naïve duplication checking that I'm not really sure I need
      return;
    }

    setSlide(
      (pivotTable) => pivotTable.copyWith(
        source: pivotTable.source.copyWith(
          files: copyWithAdded(pivotTable.source.files, file),
        ),
      ),
    );

    await pivot_table
        .addFile(
          report: slideshow,
          pivotTable: initialSlide.identifier,
          fileName: file,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onOptionAdded(String option, int filterIndex) async {
    setSlide(
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
          report: slideshow,
          pivotTable: initialSlide.identifier,
          filter: filterIndex,
          option: option,
        )
        .then(_updateAfterEdition);
  }

  // This function should handle invalid deletion cases. That is, when the
  // option is the last one in the filter, the user shouldn't be allowed to delete
  // it
  Future<void> onOptionRemoved(String option, int filterIndex) async {
    if (initialSlide.filters[filterIndex].selectedValues.length == 1) {
      return;
    }

    setSlide(
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
          report: slideshow,
          pivotTable: initialSlide.identifier,
          filter: filterIndex,
          option: option,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onOptionSwitched(String option, int filterIndex) async {
    setSlide(
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
          report: slideshow,
          pivotTable: initialSlide.identifier,
          filter: filterIndex,
          option: option,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onFilterDeleted(int filterIndex) async {
    Future<void> Function() callback = () async {};

    if (initialSlide.filters[filterIndex].chartingMode == ChartingMode.chart) {
      if (initialSlide.filters.length == 1) {
        return;
      }

      var newChartIndex = initialSlide.filters.indexWhere(
        (filter) => filter.chartingMode == ChartingMode.none,
      );
      if (newChartIndex == -1) {
        newChartIndex = initialSlide.filters.indexWhere(
          (filter) => filter.chartingMode != ChartingMode.chart,
        );
      }

      callback = () => setChart(newChartIndex);
    }

    setSlide(
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
            report: slideshow,
            pivotTable: initialSlide.identifier,
            filter: filterIndex,
          ),
        )
        .then(_updateAfterEdition);
  }

  Future<void> onFiltersReordered(int oldIndex, int newIndex) async {
    setSlide((pivotTable) {
      var filters = [...pivotTable.filters];
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      var filter = filters.removeAt(oldIndex);
      filters.insert(newIndex, filter);
      return pivotTable.copyWith(filters: filters);
    });

    await pivot_table.reorderFilter(
      report: slideshow,
      pivotTable: initialSlide.identifier,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  Future<void> toggleSelectionMode(int filterIndex) async {
    print("Toggling the selection mode");
    setSlide(
      (pivotTable) => pivotTable.copyWith(
        filters: copyWithReplacement(
          initialSlide.filters,
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
          report: slideshow,
          pivotTable: initialSlide.identifier,
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

    setSlide((pivotTable) {
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

      return initialSlide.copyWith(filters: filters);
    });

    pivot_table
        .setCharts(
          report: slideshow,
          pivotTable: initialSlide.identifier,
          chart: superChartIndex,
          superChart: chartIndex,
        )
        .then(_updateAfterEdition);
  }

  // Makes the filter at `filterIndex` be of charting mode `chart`; the super chart,
  // if other than the filter edited, is left untouched and all other filters
  // acquire the charting mode `none`
  Future<void> setChart(int filterIndex) async {
    setSlide(
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
          report: slideshow,
          pivotTable: initialSlide.identifier,
          chart: filterIndex,
        )
        .then(_updateAfterEdition);
  }

  Future<void> setSuperChart(int filterIndex) async {
    setSlide(
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
          report: slideshow,
          pivotTable: initialSlide.identifier,
          superChart: filterIndex,
        )
        .then(_updateAfterEdition);
  }

  Future<void> unsetSuperChart() async {
    setSlide(
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
          report: slideshow,
          pivotTable: initialSlide.identifier,
          superChart: -1,
        )
        .then(_updateAfterEdition);
  }

  Future<void> onFilterSelected(PivotTableLevel level) async {
    setSlide(
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
          report: slideshow,
          pivotTable: initialSlide.identifier,
          level: level,
        )
        .then((newFilter) {
          setSlide(
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

  Future<void> setAggregateFunction(
    AggregateFunctionType aggregateFunction,
  ) async {
    setSlide(
      (pivotTable) => pivotTable.copyWith(aggregateFunction: aggregateFunction),
    );

    await pivot_table
        .setAggregateFunction(
          slideshow: slideshow,
          pivotTable: initialSlide.identifier,
          aggregateFunction: aggregateFunction,
        )
        .then(_updateAfterEdition);
  }

  Future<void> setFilterFunction(FilterFunctionType filterFunction) async {
    setSlide(
      (pivotTable) => pivotTable.copyWith(filterFunction: filterFunction),
    );

    await pivot_table
        .setFilterFunction(
          slideshow: slideshow,
          pivotTable: initialSlide.identifier,
          filterFunction: filterFunction,
        )
        .then(_updateAfterEdition);
  }

  void toggleAutomaticTitle() {
    setSlide(
      (pivotTable) =>
          pivotTable.copyWith(automaticTitle: !pivotTable.automaticTitle),
    );
  }
}
