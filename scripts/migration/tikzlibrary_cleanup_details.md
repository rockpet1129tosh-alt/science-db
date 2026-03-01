# Standalone図ファイル tikzlibrary削除リスト

**実行日時:** 2026-03-01  
**対象:** physics-db/university_exam 配下の全standalone図ファイル  
**最適化ファイル数:** 31 / 39

---

## circuit-basics (16ファイル)

### 01_kirchhoff
- `fig_em_cb_01_01_q.tex` 
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cb_01_02_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cb_01_03_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cb_01_04_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 02_charge-conservation-1
- `fig_em_cb_02_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 03_charge-conservation-2
- `fig_em_cb_03_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 04_capacitor-charging
- `fig_em_cb_04_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 05_capacitor-internal-1
- `fig_em_cb_05_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 06_capacitor-internal-2
- `fig_em_cb_06_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 07_capacitor-internal-3
- `fig_em_cb_07_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 08_add-battery-resistor
- `fig_em_cb_08_01_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cb_08_02_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 09_add-battery-capacitor
- `fig_em_cb_09_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 10_add-capacitor-discharge
- `fig_em_cb_10_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 11_add-three-plates
- `fig_em_cb_11_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 12_add-four-plates
- `fig_em_cb_12_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

---

## circuit-extent (10ファイル)

### 02_non-ohmic-resistor
- `fig_em_cx_02_01_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cx_02_02_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cx_02_03_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 03_equivalent-resistance
- `fig_em_cx_03_01_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cx_03_02_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cx_03_03_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cx_03_04_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

- `fig_em_cx_03_05_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 04_infinite-switching-1
- `fig_em_cx_04_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

### 05_infinite-switching-2
- `fig_em_cx_05_00_q.tex`
  - 削除: `patterns`, `angles`, `quotes`, `calc`
  - 残存: `arrows.meta`

---

## electric-field (5ファイル)

### 04_from-potential-1
- `fig_em_ef_04_03_a.tex`
  - 削除: `calc`
  - 残存: `decorations.markings`, `arrows.meta`

- `fig_em_ef_04_03_q.tex`
  - 削除: `calc`
  - 残存: `decorations.markings`, `arrows.meta`

### 05_from-potential-2
- `fig_em_ef_05_01_a.tex`
  - 削除: `calc`, `patterns`, `angles`, `quotes`
  - 残存: `decorations.markings`, `arrows.meta`

### 09_add-equipotential-lines
- `fig_em_ef_09_01_a.tex`
  - 削除: `calc`
  - 残存: `decorations.markings`, `arrows.meta`

- `fig_em_ef_09_01_q.tex`
  - 削除: `calc`
  - 残存: `decorations.markings`, `arrows.meta`

---

## 最適化されなかったファイル (8ファイル)

以下のファイルは全てのライブラリが使用されていたため、削除なし:

1. `fig_em_cb_06_01_q.tex` (circuit-basics)
2. `fig_em_cx_06_01_q.tex` (circuit-extent)
3. `fig_em_cx_06_02_q.tex` (circuit-extent)
4. `fig_em_cx_06_03_q.tex` (circuit-extent)
5. `fig_em_cx_06_04_q.tex` (circuit-extent)
6. `fig_em_ef_03_06_a.tex` (electric-field)
7. `fig_me_ec_01_01_a.tex` (mechanics)
8. `fig_me_ec_01_01_q.tex` (mechanics)

---

## 統計

- **総ファイル数:** 39
- **最適化済み:** 31 (79.5%)
- **最適化不要:** 8 (20.5%)

## 削除されたライブラリの内訳

| ライブラリ | 削除回数 |
|-----------|---------|
| `patterns` | 27回 |
| `angles` | 27回 |
| `quotes` | 27回 |
| `calc` | 31回 |

## 効果

- 回路図では `arrows.meta` のみで十分（circuitikz が主体）
- 電場図では `decorations.markings` と `arrows.meta` が主に使用
- 角度表示が必要な図のみ `angles` と `quotes` を保持
- 座標計算を使わない図から `calc` を削除

**コンパイル速度の改善とメンテナンス性向上を達成**
