"""Tests for OAuth CSRF state parameter validation."""

import time
from unittest.mock import patch

import pytest

from app import _oauth_states, _cleanup_expired_states, OAUTH_STATE_TTL


@pytest.fixture(autouse=True)
def clear_state_store():
    """Ensure a clean state store for every test."""
    _oauth_states.clear()
    yield
    _oauth_states.clear()


class TestStateStore:
    """Tests for the in-memory state store and cleanup."""

    def test_cleanup_removes_expired_states(self):
        _oauth_states["old"] = time.time() - OAUTH_STATE_TTL - 1
        _oauth_states["fresh"] = time.time()
        _cleanup_expired_states()
        assert "old" not in _oauth_states
        assert "fresh" in _oauth_states

    def test_cleanup_keeps_all_when_none_expired(self):
        _oauth_states["a"] = time.time()
        _oauth_states["b"] = time.time()
        _cleanup_expired_states()
        assert len(_oauth_states) == 2


class TestAuthCallback:
    """Tests for /auth/callback state validation."""

    def test_missing_state_rejected(self):
        """Callback without a state parameter should redirect with error."""
        from fastapi.testclient import TestClient
        from app import app

        client = TestClient(app, follow_redirects=False)
        resp = client.get("/auth/callback", params={"code": "fake_code"})
        assert resp.status_code == 307
        assert "error=" in resp.headers["location"]
        assert "Invalid" in resp.headers["location"] or "missing" in resp.headers["location"].lower()

    def test_invalid_state_rejected(self):
        """Callback with a state that was never issued should redirect with error."""
        from fastapi.testclient import TestClient
        from app import app

        client = TestClient(app, follow_redirects=False)
        resp = client.get("/auth/callback", params={"code": "fake_code", "state": "bogus_state"})
        assert resp.status_code == 307
        assert "error=" in resp.headers["location"]

    def test_expired_state_rejected(self):
        """Callback with an expired state should redirect with error."""
        from fastapi.testclient import TestClient
        from app import app

        expired_state = "expired_token"
        _oauth_states[expired_state] = time.time() - OAUTH_STATE_TTL - 1

        client = TestClient(app, follow_redirects=False)
        resp = client.get("/auth/callback", params={"code": "fake_code", "state": expired_state})
        assert resp.status_code == 307
        assert "error=" in resp.headers["location"]
        assert "expired" in resp.headers["location"].lower()
        # State should be consumed even if expired
        assert expired_state not in _oauth_states

    def test_state_is_single_use(self):
        """Using the same state twice should fail the second time."""
        from fastapi.testclient import TestClient
        from app import app

        reused_state = "single_use_token"
        _oauth_states[reused_state] = time.time()

        client = TestClient(app, follow_redirects=False)

        # First use: state is valid (will fail on token exchange, but state validation passes)
        # We just need to confirm the state was consumed
        client.get("/auth/callback", params={"code": "fake_code", "state": reused_state})
        assert reused_state not in _oauth_states

        # Second use: state no longer exists
        resp = client.get("/auth/callback", params={"code": "fake_code", "state": reused_state})
        assert resp.status_code == 307
        assert "error=" in resp.headers["location"]


class TestAuthGoogle:
    """Tests for /auth/google state generation."""

    def test_google_auth_stores_state(self):
        """Initiating OAuth should store a state token."""
        from fastapi.testclient import TestClient
        from app import app

        client = TestClient(app, follow_redirects=False)
        resp = client.get("/auth/google")

        assert resp.status_code == 307
        assert len(_oauth_states) == 1

        state_token = list(_oauth_states.keys())[0]
        # State should appear in the redirect URL
        assert state_token in resp.headers["location"]

    def test_each_request_generates_unique_state(self):
        """Multiple OAuth initiations should each produce a unique state."""
        from fastapi.testclient import TestClient
        from app import app

        client = TestClient(app, follow_redirects=False)
        client.get("/auth/google")
        client.get("/auth/google")

        assert len(_oauth_states) == 2
        states = list(_oauth_states.keys())
        assert states[0] != states[1]
