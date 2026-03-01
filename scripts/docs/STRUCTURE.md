# Physics-DB プロジェクト構成

## 📁 フォルダ構成

```
physics-db/
├── university_exam/
│   └── physics-standard/
│       ├── em_electromagnetism/       # 電磁気学
│       ├── me_mechanics/               # 力学
│       ├── wd_wave/                    # 波
│       ├── td_thermodynamics/          # 熱力学
│       ├── mp_modern-physics/          # 現代物理
│       ├── ps_a.tex                    # 親ファイル（答え版）
│       └── ps_q.tex                    # 親ファイル（問題版）
└── scripts/
    ├── compilation/                    # コンパイルスクリプト
    └── migration/                      # データ移行・リネームスクリプト
```

## 🏷️ ファイル命名規則

### 図ファイル (LaTeX)
```
fig_[教科コード]_[内容]_[チャプター]_[図番号]/
├── fig_[教科コード]_[内容]_[チャプター]_[図番号]_a.tex    # 答え版
└── fig_[教科コード]_[内容]_[チャプター]_[図番号]_q.tex    # 問題版
```

**例:**
- `fig_em_ef_04_03_a.tex` - 電磁気学 → 電場 → 第04章 → 図03 → 答え版
- `fig_me_ec_01_01_q.tex` - 力学 → 制約・角度 → 第01章 → 図01 → 問題版

### 生成PDF
```
fig_[教科コード]_[内容]_[チャプター]_[図番号]_[a/q].pdf
```

## 🔤 教科コード

| コード | 教科名 | 説明 |
|--------|--------|------|
| `em` | Electromagnetism | 電磁気学 |
| `me` | Mechanics | 力学 |
| `wd` | Wave | 波 |
| `td` | Thermodynamics | 熱力学 |
| `mp` | Modern Physics | 現代物理 |

## 📦 パッケージ・TikZライブラリ

### 親ファイル (ps_a.tex, ps_q.tex)

**削除済みパッケージ（スタンドアロン化）:**
- `autobreak`
- `lua-ul`
- `fancybox`
- `float`
- `angles`, `quotes`, `shapes.geometric` (tikzlibraries)

**使用中のパッケージ:**
```latex
\usepackage{tikz}
\usetikzlibrary{patterns,arrows.meta,calc}
\usepackage{circuitikz}
\usepackage{luatexja}
```

### スタンドアロン図

各図ファイルは独立して以下をインポート：
```latex
\usepackage{tikz}
\usetikzlibrary{angles,quotes,arrows.meta,calc,intersections}
\usepackage{amsmath}
\usepackage{luatexja}
```

**重要:** `calc` ライブラリは `let...in` 構文を使う図では必須

## 🐛 既知の問題と修正

### 修正済み
- ✅ fig_em_ef_04_03_a.tex - `calc` ライブラリ追加（TikZ let...in 構文対応）
- ✅ fig_em_ef_09_01_a.tex - `calc` ライブラリ追加（TikZ let...in 構文対応）

### グラフィックスのプレビュー
- 複雑なTikZ図形（電場図等）は Yazi プレビューで表示されないことがあり、SumatraPDF での閲覧推奨
- Yazi プレビュー解像度: 1200×1600（lanczos3フィルタ）

## 📋 コンパイル情報

**エンジン:** LuaLaTeX (TeX Live 2025)  
**ドキュメントクラス:** jlreq（日本語対応）  
**Lua対応:** luatexja パッケージで日本語テキスト処理

**コンパイルコマンド:**
```powershell
lualatex -interaction=nonstopmode ps_a.tex
lualatex -interaction=nonstopmode ps_q.tex
```

## 📊 統計

- **総スタンドアロン図数:** 39個
- **最適化済み図:** 31個（不要なティクズライブラリを削除）
- **保護済み図:** 8個（全ライブラリが必須）
- **総PDF生成数:** 121個（コンパイル成功）

## 🔄 最近の作業履歴

| 日時 | 内容 | 結果 |
|------|------|------|
| 2026-03-01 | LaTeX パッケージ最適化 | 4パッケージ削除 |
| 2026-03-01 | TikZ ライブラリ最適化 | 31ファイル最適化 |
| 2026-03-01 | 電場図の TikZ 構文修正 | 2ファイル修正（calc 追加） |

## ✅ 完成チェックリスト

- [x] 全image PDFコンパイル成功（121/121）
- [x] スタンドアロン図コンパイル成功（39/39）
- [x] 不要なパッケージ削除
- [x] TikZライブラリ最適化
- [ ] 全図の内容確認（進行中）
- [ ] 最終 PDF デリバリー準備

## � 将来構想: Science-DB への統合

### 長期ビジョン

このプロジェクト（physics-db）は、最終的に **science-db** リポジトリの一部となります。

```
science-db/
├── university_exam/
│   ├── physics-standard/         ← このプロジェクト
│   │   ├── em_electromagnetism/
│   │   ├── me_mechanics/
│   │   ├── wa_wave/
│   │   ├── th_thermodynamics/
│   │   ├── mp_modernphysics/
│   │   └── ... (ps_a.tex など)
│   │
│   ├── chemistry-standard/       ← 将来追加
│   │   ├── or_organic-chemistry/
│   │   ├── in_inorganic-chemistry/
│   │   └── ...
│   │
│   ├── biology-standard/         ← 将来追加
│   └── earth-science-standard/   ← 将来追加
│
└── high-school-exam/
    ├── physics-chemistry/        ← 物理・化学混在
    ├── biology-earth-science/    ← 生物・地学混在
    └── integrated-science/       ← 全科目統合問題
```

### 設計原則

**高校入試の実情に対応:**
- 高校入試では物理・化学が混在して出題される
- そのため `chemistry-standard` は `physics-standard` と同階層に配置
- 各科目の標準形式は `[科目]-standard` で統一

**独立開発戦略:**
- 現在: `physics-db` と `math-db` は独立したリポジトリ
- 将来: 各リポジトリが充実した段階で `science-db` に統合
- 他科目: `japanese-db`, `english-db`, `social-studies-db` も同様に独立→統合

### マイルストーン

| フェーズ | タイムライン | 内容 |
|---------|------------|------|
| **Phase 1** | 2026年Q1 | physics-db 充実（電磁気学・力学） |
| **Phase 1** | 2026年Q1 | math-db 開始 |
| **Phase 2** | 2026年Q2-Q3 | chemistry-standard 追加 |
| **Phase 3** | 2026年Q3-Q4 | high-school-exam/physics-chemistry 統合問題 |
| **Phase 4** | 2026年Q4- | science-db リポジトリ統合 |

## �📝 注記

このドキュメントは定期的に更新されています。  
最終更新: 2026年3月1日
