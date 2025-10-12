from pandas import Timestamp

class ReportPreview():
    def __init__(self, preview: str, name: str, identifier: str, last_open: Timestamp):
        self.preview = preview
        self.name = name
        self.identifier = identifier
        self.last_open = last_open

    def to_dict(self):
        return {
            'preview': self.preview,
            'name': self.name,
            'identifier': self.identifier,
            'last_open': self.last_open.isoformat()
        }

class RecentReportsResponse():
    def __init__(self, reports: list[ReportPreview], has_more: bool, last_report: str | None):
        self.reports = reports
        self.has_more = has_more
        self.last_report = last_report
    
    def to_dict(self):
        return {
            'reports': [ preview.to_dict() for preview in self.reports ],
            'has_more': self.has_more,
            'last_report': self.last_report
        }
