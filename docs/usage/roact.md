# Using Otter with Roact

Otter can be used with a Roact feature called **bindings** to very concisely animate Roact elements. For more information on bindings themselves, see the [Roact API documentation](https://roblox.github.io/roact/advanced/bindings-and-refs/) on bindings.

!!! warning
    Bindings are only present in Roact 1.0 or greater.

## Updating bindings with a motor

You can update bindings in a motor very simply:

```lua
local binding, setBindingValue = Roact.createBinding(0)

motor:onStep(function(value)
    setBindingValue(value)
end)
```
