from pandas import Timestamp

def slide_from_json(json) -> dict:
    return {
        'title': json['title'],
        'identifier': json['identifier'],
        'creation_date': Timestamp(json['creation_date']),
        'last_edit': Timestamp(json['last_edit']),
        'preview': json['preview'],
    }
