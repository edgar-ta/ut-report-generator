from enum import Enum, EnumMeta

class RouteEnumMeta(EnumMeta):
    def __new__(meta_class, class_name, base_classes, class_dict):
        base_prefix = None
        for base in reversed(base_classes):
            base_prefix = getattr(base, "_prefix", None)
            if base_prefix is not None:
                break

        local_prefix = class_dict.get("_prefix", "")
        prefix = f"{(base_prefix or '')}/{local_prefix}".replace("//", "/")

        new_class_dict = EnumMeta.__prepare__(class_name, base_classes)

        for key, value in class_dict.items():
            if key.startswith("_"):
                new_class_dict[key] = value
                continue

            if isinstance(value, str) and key.isupper():
                value = f"{prefix}/{value}".replace("//", "/")

            new_class_dict[key] = value

        return super().__new__(meta_class, class_name, base_classes, new_class_dict)


class RouteEnum(str, Enum, metaclass=RouteEnumMeta):
    """Enum que añade automáticamente un prefijo, heredando el más cercano."""
    pass

class API_ROUTE(RouteEnum):
    _prefix = ""

    HELLO = "hello"

class SLIDESHOW(RouteEnum):
    _prefix = f"{API_ROUTE._prefix.value}/report"

    COMPILE = "compile"
    DELETE = "delete"
    EXPORT = "export"
    GET_RECENT = "get_recent"
    GET = "get"
    IMPORT = "import"
    RENAME = "rename"
    START_AS_REPORT = "start_with_image_slide"
    START_AS_VISUALIZATION = "start_with_pivot_table"
    TOGGLE_MODE = "toggle_mode"

class SLIDE(RouteEnum):
    _prefix = f"{API_ROUTE._prefix.value}/slide"

    RENAME = "rename"
    DELETE = "delete"

class PIVOT_TABLE(RouteEnum):
    _prefix = f"{API_ROUTE._prefix.value}/pivot_table"

    ADD_FILE = "add_file"
    CREATE = "create"
    GET = "get"
    REMOVE_FILE = "remove_file"
    REORDER_FILTER = "reorder_filter"
    SET_AGGREGATE = "set_aggregate_function"
    SET_CHARTS = "set_charts"
    SET_FILTER = "set_filter_function"

class IMAGE_SLIDE(RouteEnum):
    _prefix = f"{API_ROUTE._prefix.value}/image_slide"

    CREATE = "create"
    EDIT = "edit"

class DATA_FILTER(RouteEnum):
    _prefix = f"{PIVOT_TABLE._prefix.value}/filter"

    ADD_OPTION = "add"
    CREATE = "create"
    DELETE = "delete"
    REMOVE_OPTION = "remove"
    SWITCH_OPTION = "switch"
    TOGGLE_MODE = "toggle_selection_mode"
