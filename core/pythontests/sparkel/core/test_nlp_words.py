import unittest

from sparkel.nlp.words import word_count


class WordsTestCase(unittest.TestCase):

    def setUp(self):
        self.text = u"This is an simple test case for Spark and Bazel!"

    # <prefix>_<function_name>
    def test_word_count(self):
        expectation = 10
        actual = word_count(self.text)


if __name__ == '__main__':
    unittest.main()