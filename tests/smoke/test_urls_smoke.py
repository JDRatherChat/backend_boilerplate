import sys

from django.test import TestCase
from django.urls import get_resolver, resolve, reverse


class ProjectNamedURLSmokeTests(TestCase):

    def test_project_named_urls_resolve(self):
        """
        Smoke test to ensure named project URLs can be reversed and resolved.

        - Skips Django admin and debug toolbar routes.
        - Only tests routes where the resolved view module starts with 'apps.'.
        """
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
                results.append(f"[OK] {route} -> {url}")
            except Exception as e:
                results.append(f"[FAIL] {route}: {e}")
                self.fail(f"Route '{route}' failed to resolve: {e}")

        if not tested_routes:
            self.skipTest("No project routes matched filter — skipped all.")

        message = (
            f"[SmokeTest] Tested {len(tested_routes)} routes, "
            f"skipped {len(skipped_routes)}"
        )
        print(message)
        for line in results:
            print(line, file=sys.stdout)
