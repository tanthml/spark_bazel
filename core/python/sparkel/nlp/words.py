"""
Implement your library here
"""


def word_count(text):
    """
    Count number word in text

    Args:
        text (str): string text

    Returns:
        (int): number of word in text

    """
    if isinstance(text, str):
        tokens = text.split(" ")
    else:
        tokens = []

    return len(tokens)