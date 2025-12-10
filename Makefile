.PHONY: update
update:
	nix flake update --flake ~/.config/home-manager
	git add flake.lock
	git commit -m "update inputs - $$(date '+%Y-%m-%d %H:%M:%S')"
