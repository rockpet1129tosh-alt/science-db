# physics-db パッケージ・ライブラリ 削除候補レポート

**分析日時:** 2026-03-01  
**対象:** physics-db/university_exam/physics-standard/ 配下の全 .tex ファイル
**更新:** anglesとquotesライブラリは実際に使用されていることを確認（初回分析エラー修正）

---

## 削除推奨パッケージ (4つ)

### 1. `autobreak`
- **使用状況:** 使用なし
- **親ファイル:** ps_a.tex, ps_q.tex の両方で読み込み
- **推奨:** 削除可能

### 2. `fancybox`
- **使用状況:** 使用なし
- **検索パターン:** `\shadowbox`, `\doublebox`, `\ovalbox`, `\Ovalbox`, `\cornersize`
- **推奨:** 削除可能

### 3. `float`
- **使用状況:** 使用なし
- **検索パターン:** `\floatstyle`, `\restylefloat`, `\newfloat`, `[H]`
- **推奨:** 削除可能

### 4. `lua-ul`
- **使用状況:** 使用なし
- **検索パターン:** `\underLine`, `\strikeThrough`, `\highLight`
- **推奨:** 削除可能

---

## 削除推奨 tikzlibrary (1つ)

### ~~1. `angles`~~ - **削除不可**（初回分析エラー）
- **実際の使用状況:** me_mechanics/eom-constraints で使用中
- **用途:** `pic{angle=...}` 構文で角度を描画
- **理由:** angle eccentricity, angle radius などのオプションで使用
- **推奨:** **保持必須**

### ~~2. `quotes`~~ - **削除不可**（初回分析エラー）
- **実際の使用状況:** angles と組み合わせて使用中
- **用途:** `pic["$\theta$", ...]` 記法で角度にラベルをつける
- **理由:** TikZ の quotes 記法を有効化
- **推奨:** **保持必須**

### 1. `shapes.geometric`
- **使用状況:** 使用なし
- **親ファイル:** ps_q.tex のみで読み込み（ps_a.tex には含まれない）
- **推奨:** 削除可能

---

## ~~削除推奨 tikzlibrary (3つ)~~

~~### 1. `angles`~~
~~- **使用状況:** 使用なし~~
~~- **親ファイル:** ps_a.tex, ps_q.tex の両方で読み込み~~
~~- **推奨:** 削除可能~~

~~### 2. `quotes`~~
~~- **使用状況:** 使用なし（検索では3ファイルでヒットするが実際に quotes ライブラリ特有の構文は未使用）~~
~~- **親ファイル:** ps_a.tex, ps_q.tex の両方で読み込み~~
~~- **推奨:** 削除可能（念のため手動確認推奨）~~

~~### 3. `shapes.geometric`~~
- **使用状況:** 使用なし
- **親ファイル:** ps_q.tex のみで読み込み（ps_a.tex には含まれない）
- **推奨:** 削除可能
ngles` | 使用中 | 角度描画（初回分析で見逃し） |
| `quotes` | 使用中 | 角度ラベル（初回分析で見逃し） |
| `arrows.meta` | 38 files | 矢印で多用 |
| `calc` | 1 files | 座標計算 |
| `patterns` | 3 files | パターン塗り |

---

## 初回分析の問題点

**検出漏れ理由:**
- `angles`: 直接的な `\pic{angle` パターンのみ検索、オプション形式（`angle eccentricity=`, `angle radius=`）を見逃し
- `quotes`: TikZ の quotes 記法 `pic["label", ...]` は quotes ライブラリ必須だが、検索パターンが不十分

**教訓:**
- TikZ ライブラリはオプション形式でも使用される
- 実際のコンパイルテストが必要
- 自動分析は参考程度にとどめ、手動確認必須
## 使用中で削除不可のパッケージ

| パッケージ | 使用ファイル数 | 備考 |
|-----------|----------------|------|
| `caption` | 4 files | 必須 |
| `circuitikz` | 25 files | 回路図で多用 |
| `enumitem` | 2 files | リスト設定 |
| `needspace` | 2 files | 改ページ制御 |
| `physics` | 4 files | 物理記号 |
| `titleps（修正版）

### 1. 親ファイル ps_a.tex の修正

**修正不要** - 現状維持
```latex
\usetikzlibrary{patterns,angles,quotes,arrows.meta,calc}
```

### 2. 親ファイル ps_q.tex の修正

**修正前 (Line ~30):**
```latex
\usetikzlibrary{patterns,angles,quotes,arrows.meta,calc,shapes.geometric}
```

**修正後:**
```latex
\usetikzlibrary{patterns,angles,quotes,arrows.meta,calc}
```
（`shapes.geometric` のみ削除）

**削除するパッケージ:**
```latex
% 以下を削除
### 2. 親ファイル ps_q.tex の修正

**修正前 (Line ~30):**
```latex
\usetikzlibrary{patterns,angles,quotes,arrows.meta,calc,shapes.geometric}
```

**修正後:**
```latex
\usetikzlibrary{patterns,arrows.meta,calc}
```

**削除するパッケージ:**
```latex
% 以下を削除（ps_a.tex と同様）
% \usepackage{autobreak}
% \usepackage{lua-ul}
% \usepackage{fancybox}
% \usepackage{float}
```

---

## 削除の影響（修正版）

- **tikzlibrary削除:** `shapes.geometric` のみ（ps_q.tex から）
- **パッケージ削除:** 4つ（autobreak, lua-ul, fancybox, float）
- **コンパイル速度:** わずかな改善
- **メンテナンス性:** 向上（不要な依存関係の削除）
- **リスク:** 最小限（未使用のみ削除）

---

## テスト手順

1. バックアップを取る
2. 親ファイル（ps_a.tex, ps_q.tex）を修正
3. 全ファイルをコンパイル: `.\scripts\compile\compile_all.ps1`
4. エラーがないことを確認
5. PDF出力を目視確認して問題がないことを確認

---

**注意:** 
- anglesとquotesは必須です（初回分析で誤って削除候補としていました）
- 実際のコンパイルテストで判明したため、レポートを修正しました
- 自動分析結果は参考程度にとどめ、必ず手動確認とコンパイルテストを実施してください

---

**作業完了項目:**
- ✅ me_mechanics/eom-constraints の図をstandalone形式で分離（fig_me_ec_01_01_a）
- ✅ ps_a.texのコンパイル成功確認（33ページ）
