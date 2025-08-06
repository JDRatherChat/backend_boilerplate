# apps/tests/test_urls.py
import datetime
import os

from django.test import TestCase
from django.urls import get_resolver, resolve, reverse

LOG_DIR = os.path.join("logs", "test_logs")
os.makedirs(LOG_DIR, exist_ok=True)


class ProjectNamedURLSmokeTests(TestCase):
    def test_project_named_urls_resolve(self):
        """Ensure all project app URL names can be reversed and resolved."""

        resolver = get_resolver()
        route_names = [
            name
            for name in resolver.reverse_dict.keys()
            if isinstance(name, str)
            and not name.startswith("admin")
            and not name.startswith("djdt")
        ]

        tested_routes, skipped_routes, results = [], [], []

        for route in route_names:
            try:
                url = reverse(route)
                resolved = resolve(url)
                if not resolved.func.__module__.startswith("apps."):
                    skipped_routes.append(route)
                    continue
                tested_routes.append(route)
                self.assertEqual(resolved.view_name, route)
                results.append(f"✅ {route} -> {url}")
            except Exception as e:
                results.append(f"❌ {route} failed: {e}")
                self.fail(f"Route '{route}' failed to resolve: {e}")

        # Don’t fail if some routes are skipped — only if none tested
        if not tested_routes:
            self.skipTest("No project routes matched filter — skipped all.")

        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        log_path = os.path.join(LOG_DIR, f"url_smoke_{timestamp}.log")
        with open(log_path, "w", encoding="utf-8") as f:
            f.write("\n".join(results))

        print(
            f"\n[SmokeTest] Tested {len(tested_routes)} routes, skipped {len(skipped_routes)}"
        )
        print(f"[SmokeTest] Log saved at {log_path}")
