enum PivotTableLevel { group, year, subject, professor, unit }

String levelToSpanish(PivotTableLevel level) {
  switch (level) {
    case PivotTableLevel.group:
      return "Grupo";
    case PivotTableLevel.professor:
      return "Profesor";
    case PivotTableLevel.subject:
      return "Materia";
    case PivotTableLevel.unit:
      return "Unidad";
    case PivotTableLevel.year:
      return "Año";
  }
}
