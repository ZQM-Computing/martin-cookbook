import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
CONFIG = ROOT / "examples" / "01-table-source" / "config.yaml"
GUIDE = ROOT / "examples" / "01-table-source" / "README.md"
WORKFLOW = ROOT / ".github" / "workflows" / "tests.yml"
SMOKE = ROOT / "tests" / "smoke-test.sh"


class TableSourceContractTests(unittest.TestCase):
    def test_config_publishes_only_explicit_table(self):
        config = CONFIG.read_text(encoding="utf-8")
        self.assertIn("connection_string: ${DATABASE_URL}", config)
        self.assertIn("tables:", config)
        self.assertIn("table: places", config)
        self.assertIn("geometry_column: geom", config)
        self.assertIn("id_column: id", config)

    def test_workflow_uses_pinned_martin_and_disposable_postgis(self):
        workflow = WORKFLOW.read_text(encoding="utf-8")
        smoke = SMOKE.read_text(encoding="utf-8")
        self.assertIn("postgis/postgis:16-3.5", workflow)
        self.assertIn("ghcr.io/maplibre/martin:1.16.1", smoke)

    def test_docs_bound_the_security_and_validation_claims(self):
        guide = GUIDE.read_text(encoding="utf-8").lower()
        self.assertIn("read-only access", guide)
        self.assertIn("does not prove production throughput", guide)


if __name__ == "__main__":
    unittest.main()
