# Ponytail Audit — RDB Model

Whole-repo over-engineering audit. Findings ranked biggest cut first.

## Findings

### 1. `yagni/stdlib` — Custom YAML parser (2,933 lines)

Hand-rolled YAML parser in Elm when the JS side already uses the `yaml` npm package. Decode YAML in JS, send JSON through ports using `elm/json`. Deletable.

**Files:** `src/Yaml/Decode.elm`, `src/Yaml/Encode.elm`, `src/Yaml/Parser.elm`, `src/Yaml/Parser/Ast.elm`, `src/Yaml/Parser/Document.elm`, `src/Yaml/Parser/String.elm`, `src/Yaml/Parser/Util.elm`

### 2. `yagni` — SplitPanel custom implementation (826 lines)

Full custom split-pane with `Bounded` value type, resize logic, mouse subscriptions, custom update configs. CSS flex + a simple drag divider is ~30 lines.

**Files:** `src/SplitPanel/SplitPane.elm`, `src/SplitPanel/Bound.elm`

### 3. `shrink` — Repeated SVG icon boilerplate

7+ modules copy-paste identical SVG wrapper attributes (`Px 24`, `PaintNone`, `StrokeLinecapRound`, etc.) and the same `TypedSvg.Types` import. Extract to a shared `Svg.icon` helper.

**Files:** `src/FilePicker.elm`, `src/SaveDomain/SaveDomain.elm`, `src/Error/Error.elm`, `src/Navigation/ViewNavigation.elm`, `src/UndoRedo/ViewUndoRedo.elm`, `src/ViewControl/AddView.elm`, `src/ViewEditor/Editor.elm`

### 4. `yagni` — Session.elm (10 lines)

Single 3-field type alias in its own module. Inline into Main.elm.

**File:** `src/Session.elm`

### 5. `yagni` — Thin Action wrapper modules (~144 lines)

Each defines an `Action` type and immediately foldl-applies it. Inline into parent modules.

**Files:** `src/ContainerMenu/MenuActions.elm`, `src/ViewControl/AddViewActions.elm`, `src/ViewControl/ViewControlActions.elm`, `src/UndoRedo/ViewUndoRedoActions.elm`

### 6. `delete` — Dead no-op function

`modifyYamlValue()` in `index.js` — 13 lines of fully commented-out regex replacements. Function body is all comments; pure pass-through. Remove it and all callers.

**File:** `index.js` (lines 295–313)

### 7. `shrink` — Error.elm showList dedup pipeline

`Set.fromList >> Set.toList >> List.foldl` — unnecessary dedup pipeline. Use the fold directly.

**File:** `src/Error/Error.elm` (line 235)

### 8. `shrink` — `exposing (..)` everywhere

14 modules expose everything; 4 imports also use `(..)`. Makes dependencies untraceable and bloats dead-code elimination. Use explicit exports.

---

**Net:** ~-4,200 source lines, ~500 lines of duplication eliminated.
