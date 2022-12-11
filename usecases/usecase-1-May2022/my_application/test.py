#!/usr/bin/env python
import unittest
import application


class TestHello(unittest.TestCase):

    def setUp(self):
        application.application.testing = True
        self.app = application.application.test_client()

    def test_hello(self):
        rv = self.app.get('/')
        self.assertEqual(rv.status, '200 OK')

    def test_hello_name(self):
        name = 'Ankur'
        url = '/hello/%s' % {name}
        rv = self.app.get(url)
        self.assertEqual(rv.status, '200 OK')


if __name__ == '__main__':
    ###########################################
    # For XML Test Report #
    import xmlrunner
    runner = xmlrunner.XMLTestRunner(output='test-reports')
    unittest.main(testRunner=runner)
    ###########################################
    unittest.main()
