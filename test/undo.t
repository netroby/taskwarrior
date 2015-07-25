#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
###############################################################################
#
# Copyright 2006 - 2015, Paul Beckingham, Federico Hernandez.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# http://www.opensource.org/licenses/mit-license.php
#
###############################################################################

import sys
import os
import unittest
# Ensure python finds the local simpletap module
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from basetest import Task, TestCase


class TestUndo(TestCase):
    def setUp(self):
        """Executed before each test in the class"""
        self.t = Task()

    def test_add_undo(self):
        """'add' then 'undo'"""
        self.t('add one')
        code, out, err = self.t('_get 1.status')
        self.assertEqual(out.strip(), 'pending')
        self.t('undo')
        code, out, err = self.t('_get 1.status')
        self.assertEqual(out.strip(), '')

    def test_add_done_undo(self):
        """'add' then 'done' then 'undo'"""
        self.t('add two')
        code, out, err = self.t('_get 1.status')
        self.assertEqual(out.strip(), 'pending')
        self.t('1 done')
        code, out, err = self.t('_get 1.status')
        self.assertEqual(out.strip(), 'completed')
        self.t('undo')
        code, out, err = self.t('_get 1.status')
        self.assertEqual(out.strip(), 'pending')

    def test_undo_en_passant(self):
        """Verify that en-passant changes during undo are an error"""
        self.t("add one")
        code, out, err = self.t.runError("undo +tag")
        self.assertIn("Command line modifications are not supported by this command.", err)


class TestBug634(TestCase):
    def setUp(self):
        self.t = Task()

    def test_undo_no_confirmation(self):
        """Undo honors confirmation=off"""

        self.t("add Test")

        # If a prompt happens, the test will timeout on input (exitcode != 0)
        code, out, err = self.t("rc.confirmation=off undo")
        self.assertIn("Task removed", out)


if __name__ == "__main__":
    from simpletap import TAPTestRunner
    unittest.main(testRunner=TAPTestRunner())

# vim: ai sts=4 et sw=4
