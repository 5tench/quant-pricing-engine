import unittest

import quant_pricing_engine


class PackageSkeletonTests(unittest.TestCase):
    def test_package_exposes_version(self) -> None:
        self.assertIsInstance(quant_pricing_engine.__version__, str)
        self.assertTrue(quant_pricing_engine.__version__)


if __name__ == "__main__":
    unittest.main()
