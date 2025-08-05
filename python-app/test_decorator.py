from collections.abc import Callable

def test_decorator[**P, R](callback: Callable[P, R]) -> Callable[P, R]:
    def outter(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling function: {callback.__name__}")
        print("Arguments: ", args)
        print("Keyword arguments: ", kwargs)
        return callback(*args, **kwargs)
    return outter
