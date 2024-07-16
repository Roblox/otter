<h1 align="center">Otter</h1>
<div align="center">
	<a href="https://github.com/Roblox/otter-internal/actions/workflows/test.yml">
		<img src="https://github.com/Roblox/otter-internal/actions/workflows/test.yml/badge.svg" alt="GitHub CI" />
	</a>
	<a href='https://coveralls.io/github/Roblox/otter-internal?branch=main'>
		<img src='https://coveralls.io/repos/github/Roblox/otter-internal/badge.svg?branch=main&amp;t=r8LIRE' alt='Coverage Status' />
	</a>
	<a href="https://roblox.github.io/otter-internal">
		<img src="https://img.shields.io/badge/docs-website-green.svg" alt="Documentation" />
	</a>
</div>

<div align="center">
	Declarative animation library for Roblox Lua built around (but not limited to) springs.
</div>

<div>&nbsp;</div>

## Running the Storybook

To see the examples [from the docs](https://roblox.github.io/otter-internal/usage/react/) in action, check out the storybook:

1. Make sure you've installed tools (you may need to run `foreman install`)
2. Run `rotrieve install` to install dependencies
3. Open the `storybook.rbxp` file in Roblox Studio
4. Click the Storybook plugin under the "Plugins" tab to open the storybook UI
5. Select the storybook titled "React + Otter"

## Running the Benchmarks

1. Make sure you've installed tools (you may need to run `foreman install`)
2. Run `rotrieve install` to install dependencies
3. Run `evaluate run default.project.json` to run the benchmarks
4. Benchmark ouptut will be generated in `bin/benchmarks`
