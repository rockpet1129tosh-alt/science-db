# subfiles パッケージ & \subfix{} 運用ガイド

**作成日**: 2026年3月4日  
**対象**: science-db における multi-parent 運用、複数入試問題プリント生成

---

## 📖 目次

1. [基本概念](#基本概念)
2. [相対パス問題と \subfix{} の役割](#相対パス問題と-subfix-の役割)
3. [\subfix{} vs \graphicspath{}](#subfixvsgraphicspath比較)
4. [science-db での階層構造](#science-db-での階層構造)
5. [複数親運用](#複数親運用)
6. [個別プリアンブル変更](#個別プリアンブル変更)
7. [ベストプラクティス](#ベストプラクティス)
8. [トラブルシューティング](#トラブルシューティング)

---

## 基本概念

### subfiles パッケージとは

**subfiles** パッケージは、複雑な TeX ドキュメントをファイル分割して管理し、各ファイル**独立コンパイル可能**かつ**親ファイルから編成可能**にするツールです。

```tex
% 親ファイル
\documentclass[jlreq]{...}
\begin{document}
    \subfile{子ファイル.tex}  ← 子ファイルを読み込む
\end{document}

% 子ファイル
\documentclass[../親ファイル.tex]{subfiles}  ← 親を指定
\begin{document}
    子コンテンツ
\end{document}
```

**key point**: 子ファイルは `\documentclass[親パス]{subfiles}` で親を指定することで、独立コンパイル時は自動で親のプリアンブルを継承します。

---

## 相対パス問題と \subfix{} の役割

### 📍 問題: 子ファイルの相対パスは階層による

```
university_exam/physics-standard/
├── ps_em_cb_01_q.tex（子ファイル、階層4深）
│   ├── \documentclass[../../../ps_q.tex]{subfiles}
│   └── \includegraphics{fig_em_cb_01/fig_em_cb_01_01_q.pdf}
│
└── fig_em_cb_01/（図フォルダ、同じ階層）
```

**コンパイルコンテキストが異なる場合、相対パスが破綻します：**

| コンテキスト | パス解釈 | 結果 |
|-----------|---------|------|
| 子 → 直接コンパイル | `fig_em_cb_01/` は子と同じ階層 | ✅ OK |
| 親 → 子を読み込む | `fig_em_cb_01/` は親から見て存在しない | ❌ 見つからない |

### ✅ 解決策: \subfix{} マクロ

```tex
\includegraphics{\subfix{fig_em_cb_01/fig_em_cb_01_01_q.pdf}}
```

**\subfix{} は何をするか:**

1. 子ファイルが **直接コンパイル** されるとき: `#1` をそのまま返す（通常のパス）
2. 親ファイルから **読み込まれる** とき: 親のコンテキストに合わせ、相対パスを自動調整

**内部動作:**

```tex
% subfiles パッケージの内部定義（デフォルト）
\providecommand{\subfix}[1]{#1}

% 親から読み込まれるとき、subfiles が自動で再定義
% (内部ロジック) 親ファイルからの相対パスを計算 → パス調整
```

---

## \subfix{} vs \graphicspath{} 比較

### 📊 両者の概要

相対パス問題を解決する別の方法として、`\graphicspath` を使う選択肢もあります。どちらを選ぶかは、文書構造と複数親対応次第です。

### 📋 機能比較表

| 項目 | \subfix{} | \graphicspath{} |
|------|----------|-----------------|
| **実装例** | `\includegraphics{\subfix{fig_em/fig.pdf}}` | `\graphicspath{{fig_em/}{../fig_em/}{...}}` + `\includegraphics{fig.pdf}` |
| **相対パス自動調整** | ⭐⭐⭐⭐⭐ 自動（subfiles が計算） | ⚠️ 手動（全パターン列挙） |
| **複数親対応** | ✅ 自動対応（親ごとに計算） | ⚠️ 全パターン列挙が必要 |
| **階層増加時の保守性** | ⭐⭐⭐⭐⭐ 変更不要 | ⭐⭐ パスリスト更新要 |
| **パス明示性** | ✅ 相対パスが見える | ❌ ファイル名のみ |
| **複雑度** | シンプル | 煩雑（特に深い階層） |
| **学習曲線** | 少し（subfiles理解要） | 易しい |
| **パフォーマンス** | ⭐⭐⭐⭐⭐ 効率的 | ⭐⭐⭐ 検索額多い |

### 🔍 \graphicspath{} の実装例

```tex
% 単純なケース: ネスト2階層まで
\graphicspath{{fig_em_cb_01/}{../fig_em_cb_01/}{./}}
\includegraphics{fig_em_cb_01_01_q.pdf}
```

**動作**: 指定されたパスのリストから順番に検索し、最初にマッチするファイルを使用。

### ⚠️ \graphicspath が science-db で課題な理由

#### 1. 階層が深い場合のパスリスト爆発

```tex
% ps_em_cb_01_q.tex: 親コンテキストに応じた全パターンを列挙する必要がある
\graphicspath{
    {fig_em_cb_01/}  % コンテキスト1: 子として直接コンパイル
    {../fig_em_cb_01/}  % コンテキスト2: ps_em_cb_q.tex から読み込まれる時
    {../../circuit-basics/01_kirchhoff/fig_em_cb_01/}  % コンテキスト3: ps_em_q.tex から
    {../../../em_electromagnetism/circuit-basics/01_kirchhoff/fig_em_cb_01/}  % コンテキスト4: ps_q.tex から
    {../../../../university_exam/physics-standard/em_electromagnetism/circuit-basics/01_kirchhoff/fig_em_cb_01/}  % プリント親からの場合
}
```

**代償**:
- ❌ 全パターンを手動で列挙
- ❌ 階層増える度に新しいパスを追加
- ❌ 保守性が低い

#### 2. 複数親運用での複雑性

同じ子ファイルを複数の親から読み込む場合、親の位置が異なるため、パスリストも異なる必要があります：

```tex
% パターンA: ps_em_cb_q.tex から読み込む場合のパスリスト
\graphicspath{{../circuit-basics/01_kirchhoff/fig_em_cb_01/}{...}}

% パターンB: prnt_exam_2024_spring.tex から読み込む場合のパスリスト
% → 全く異なるパスになる
\graphicspath{{../../../university_exam/physics-standard/em_electromagnetism/circuit-basics/01_kirchhoff/fig_em_cb_01/}{...}}
```

**問題**: 子ファイルは複数の親コンテキストに対応できない → 複数親運用が困難

#### 3. コンパイル時のパフォーマンス低下

`\graphicspath` は一致するまで全てのパスを検索するため：
- 古いバージョンの LaTeX では顕著
- パスリストが長いと検索コストが増加
- 図版が多い場合に無視できない遅延

### ✅ \graphicspath が活躍する場合

`\graphicspath` が適切なケース：

```tex
% ケース1: すべての図が共通フォルダにある場合
\graphicspath{{../../figures/}{./}}

% ケース2: ネストが浅い（1～2階層）
\documentclass[jlreq]{...}
\graphicspath{{figures/}}
\begin{document}
    \includegraphics{figure.pdf}
\end{document}

% ケース3: 子ファイルが常に1つの親からのみ呼ばれる場合
% （単一の固定親ファイル）
```

### 🎯 選択基準

| 状況 | 推奨 | 理由 |
|------|------|------|
| **science-db**（階層深、複数親） | **\subfix{}** | 自動化、保守性高、複数親対応 |
| シンプルな構造（ネスト浅） | どちらでも可 | \graphicspath でも十分 |
| 学位論文（固定親） | \graphicspath でも可 | \subfix は不要 |
| 大規模マルチドキュメント | **\subfix{}** | スケーラビリティ重視 |
| 将来の拡張可能性考慮 | **\subfix{}** | 親追加時に変更不要 |

### 💡 結論

- **\subfix{}**: subfiles パッケージが提供する機能で、相対パス自動変換を目的として設計
  - science-db のような複雑な階層・複数親運用に最適
  - 保守性が高い

- **\graphicspath{}**: 古典的な LaTeX の機能で、図版検索パスを指定
  - シンプルな文書・単一親に適している
  - 深い階層・複数親では手管理が煩雑

---

## science-db での階層構造

### 🏗️ ラッパー方式（推奨）の階層構造

```
ps_master.tex（統合エントリ）
    ↓ PSMODE=q / a で分岐

ps_q.tex / ps_a.tex（保存時コンパイル用ラッパー）
    ↓ \subfile

ps_em_q.tex / ps_em_a.tex（分野マスター）
    \documentclass[../ps_q.tex or ../ps_a.tex]{subfiles}
    ↓ \subfile

ps_em_cb_q.tex / ps_em_cb_a.tex（中項目マスター）
    \documentclass[../../ps_q.tex or ../../ps_a.tex]{subfiles}
    ↓ \subfile

ps_em_cb_01_q.tex / ps_em_cb_01_a.tex（細目ファイル）
    \documentclass[../../../ps_q.tex or ../../../ps_a.tex]{subfiles}
    ↓ \includegraphics
    
fig_em_cb_01/fig_em_cb_01_01_q.pdf（図）
    \subfix{fig_em_cb_01/fig_em_cb_01_01_q.pdf}
```

### ✅ この構成の意図

- `ps_master.tex`: 全体統合・将来拡張用（明示的に q/a を切替）
- `ps_q.tex` / `ps_a.tex`: 日常運用の入口（保存時自動コンパイルと相性が良い）
- 下位 subfiles は q 系は `ps_q.tex`、a 系は `ps_a.tex` を参照
- これにより「子ファイル直接コンパイル時のモード誤爆」を防止

### 📐 パス調整の例

細目ファイル内:
```tex
% ps_em_cb_01_q.tex （university_exam/physics-standard/em_electromagnetism/circuit-basics/01_kirchhoff/ に位置）
\documentclass[../../../ps_q.tex]{subfiles}
\begin{document}
    \includegraphics{\subfix{fig_em_cb_01/fig_em_cb_01_01_q.pdf}}
    %                                  ↑
    %   相対パス：../01_kirchhoff/fig_em_cb_01/ （親 ps_em_cb_q.tex から見て）
\end{document}
```

--

**親ファイルからのコンパイル時:**
- 例えば `ps_em_cb_q.tex` が `\subfile{01_kirchhoff/ps_em_cb_01_q.tex}` と指定
- subfiles が 親 → 子 の相対パス差分を計算
- `\subfix{}` が親コンテキストへのパスに自動変換

---

## 複数親運用

### 🎯 使用例: プリント問題集の生成

```
university_exam/physics-standard/
├── ps_master.tex（統合親）
├── ps_q.tex / ps_a.tex（運用ラッパー）
├── em_electromagnetism/
│   └── circuit-basics/
│       └── 01_kirchhoff/
│           └── ps_em_cb_01_q.tex（細目ファイル）
│
prints/（プリント用フォルダ）
├── prnt_exam_2024_spring.tex（プリント親①）
├── prnt_exam_2024_summer.tex（プリント親②）
└── prnt_exam_2024_winter.tex（プリント親③）
```

### ✅ 複数親から同じ子を読み込む

```tex
% prnt_exam_2024_spring.tex
\documentclass[../university_exam/physics-standard/ps_q.tex]{subfiles}
%            ↑
%  最上位親を親として指定（critical!）

\begin{document}
    \subfile{../university_exam/physics-standard/em_electromagnetism/circuit-basics/01_kirchhoff/ps_em_cb_01_q.tex}
    \subfile{../university_exam/physics-standard/th_thermodynamics/...}
    ...
\end{document}
```

**重要**: 複数親を使う場合は、**全てのプリント親が同じ運用ラッパー（`ps_q.tex` か `ps_a.tex`）を指定** することで、設定が一元化され、子ファイルが確実に動作します。

### 💡 複数親が機能する理由

1. 子ファイルは `\documentclass[.../ps_q.tex or .../ps_a.tex]{subfiles}` で運用親を指定
2. 各プリント親も同じ運用親（q or a）を指定
3. 運用親は共通 preamble を読むため、全コンテキストで設定が統一
4. `\subfix{}` が各親からの相対パス差分を自動計算 → 図版が正しく参照される

---

## 個別プリアンブル変更

### 状況: 特定の問題だけ異なる設定が必要

例: 問題01 は grid background、問題02 は無地背景

### ⚠️ subfiles の制限

子ファイルのプリアンブルは、**親から読み込まれると実行されません**。

```tex
% ps_em_cb_01_q.tex
\documentclass[../../../ps_q.tex]{subfiles}
\usepackage{special-package}  ← 親から読み込まれるとき「スキップ」される
\begin{document}
    ...
\end{document}
```

### ✅ 4つの解決策

#### **方法1: 親ファイルで条件分岐（推奨）**

親ファイル側で各子に対するフラグを設定:

```tex
% ps_em_cb_q.tex（中項目マスター親）
\documentclass[../../ps_q.tex]{subfiles}

\begin{document}

\newcommand{\gridBackgroundON}{1}
\subfile{01_kirchhoff/ps_em_cb_01_q.tex}
\renewcommand{\gridBackgroundON}{0}

\subfile{02_charge-conservation-1/ps_em_cb_02_q.tex}

\end{document}
```

子ファイル内で条件判定:

```tex
% ps_em_cb_01_q.tex
\documentclass[../../../ps_q.tex]{subfiles}

\begin{document}

\ifdefined\gridBackgroundON
    \tikzset{background grid/.style={
        draw=black!10, step=5mm
    }}
\fi

\subsection{キルヒホッフの法則}

\begin{tikzpicture}[background grid]
    ...
\end{tikzpicture}

\end{document}
```

**メリット**: 親が全体を制御、子は親の定義に応答  
**デメリット**: 条件分岐が複雑化する可能性

---

#### **方法2: AtBeginDocument ホック**

```tex
% ps_em_cb_01_q.tex
\documentclass[../../../ps_q.tex]{subfiles}

\AtBeginDocument{
    % 親ファイルが読み込まれた後に実行
    \tikzset{local-style/.style={grid=on}}
    \renewcommand{\myfont}{\large\bfseries}
}

\begin{document}
    ...
\end{document}
```

**メリット**: シンプル、親ファイルへの侵襲なし  
**デメリット**: 親の影響を受ける可能性

---

#### **方法3: 中間層の親ファイルを追加（複数問題で共通設定の場合）**

```
ps_em_cb_q.tex（標準版親）
    └─ ps_em_cb_01_q.tex（標準子）

ps_em_cb_special_q.tex（新規カスタム版親）
    └─ ps_em_cb_01_q.tex（同じ子）
```

```tex
% ps_em_cb_special_q.tex
\documentclass[../../ps_q.tex]{subfiles}
\usepackage{special-graphics-package}
\tikzset{grid-style/.style={...}}

\begin{document}
    \subfile{01_kirchhoff/ps_em_cb_01_q.tex}
    \subfile{02_charge-conservation-1/ps_em_cb_02_q.tex}
\end{document}
```

**メリット**: 独立した親として管理、元の親は変更なし  
**デメリット**: ファイル数増加

---

#### **方法4: ローカルマクロで本文内調整（推奨）**

最も subfiles に適った方法。プリアンブルではなく、本文内でマクロを活用:

```tex
% ps_em_cb_01_q.tex
\documentclass[../../../ps_q.tex]{subfiles}

\begin{document}

\subsection{キルヒホッフの法則}

% ローカルマクロ定義（この問題のみ有効）
\let\origTikzpicture\tikzpicture
\renewcommand{\tikzpicture}{\origTikzpicture[grid=on]}

\begin{tikzpicture}
    ...
\end{tikzpicture}

\let\tikzpicture\origTikzpicture  % リセット

\end{document}
```

**メリット**: プリアンブル変更なし、本文のみで完結  
**デメリット**: マクロ操作の知識が必要

---

### 📊 方法の選択基準

| 方法 | 少数の特例 | 複数問題の共通設定 | 軽微な変更 |
|------|---------|------------|---------|
| 1. 条件分岐 | ✅ | ❌ | ❌ |
| 2. AtBeginDocument | ❌ | ❌ | ✅ |
| 3. 中間層親 | ❌ | ✅ | ❌ |
| 4. ローカルマクロ | ✅ | ✅ | ✅ |

---

## ベストプラクティス

### science-db での推奨運用方針

#### 1. 最上位親を統一
```tex
% 全ての子ファイルで最上位親を指定
\documentclass[...相対パス.../ps_q.tex]{subfiles}
```

- **ps_q.tex** がプリアンブルの唯一の定義元
- 全子ファイルが同じパッケージ・マクロを確実に継承

#### 2. \subfix{} を図版参照すべてに適用
```tex
\includegraphics{\subfix{fig_em_cb_01/fig_em_cb_01_01_q.pdf}}
```

- 相対パスの自動調整を委任
- 親変更時のパス修正不要

#### 3. プリアンブル変更は本文内で

```tex
% ps_em_cb_01_q.tex
\documentclass[../../../ps_q.tex]{subfiles}

\begin{document}

\subsection{キルヒホッフの法則}

% この問題固有の設定（本文内）
\tikzset{problem-specific-style/.style={fill=blue!20}}

\begin{tikzpicture}[problem-specific-style]
    ...
\end{tikzpicture}

\end{document}
```

#### 4. 複数親運用では親も最相位親を指定

```tex
% prnt_exam_2024_spring.tex
\documentclass[../university_exam/physics-standard/ps_q.tex]{subfiles}
%            ↑ ps_q.tex を親として明示
\begin{document}
    \subfile{../university_exam/physics-standard/...子ファイル}
\end{document}
```

---

## トラブルシューティング

### ❌ ファイルが見つからない

**症状**: 
```
! LaTeX Error: File 'fig_em_cb_01/fig_em_cb_01_01_q.pdf' not found.
```

**原因**: `\subfix{}` が使われていない、または相対パスが誤り

**確認チェックリスト**:
- [ ] 図版参照に `\subfix{}` が使われているか
- [ ] 子ファイルの `\documentclass[...]{subfiles}` で正しい親を指定しているか
- [ ] 図フォルダが実際に存在するか

**解決策**:
```tex
% 正しい例
\includegraphics{\subfix{fig_em_cb_01/fig_em_cb_01_01_q.pdf}}

% 間違った例
\includegraphics{fig_em_cb_01/fig_em_cb_01_01_q.pdf}  ← \subfix なし
```

---

### ❌ 子を直接コンパイルするとパッケージエラー

**症状**:
```
! Undefined control sequence. \mytitle
```

**原因**: 親ファイルのプリアンブルが読み込まれていない

**確認チェックリスト**:
- [ ] 子ファイルで `\documentclass[...親ファイル...]{subfiles}` と指定しているか
- [ ] 相対パスが正確か（`../../../ps_q.tex`）

**解決策**: 親ファイルの相対パスを確認
```powershell
# Linux/Mac/PowerShell で確認
cd university_exam/physics-standard/em_electromagnetism/circuit-basics/01_kirchhoff
ls ../../../ps_q.tex  # ファイルが見えるか確認
```

---

### ❌ 複数親運用で子ファイルがコンパイルされない

**症状**: 
```
! LaTeX Error: File 'ps_em_cb_01_q.tex' not found.
```

**原因**: プリント親ファイルからの相対パスが誤り

**確認チェックリスト**:
- [ ] プリント親ファイルの `\documentclass[...]{subfiles}` で最上位親（ps_q.tex）を指定しているか
- [ ] `\subfile{}` での子ファイルへの相対パスが正確か
- [ ] 親・子ファイルが実際に存在するか

**デバッグ法**: パス深度を視覚化
```tex
% prnt_exam_2024_spring.tex
% ├─ prints/
% └─ university_exam/physics-standard/
%    ├─ ps_q.tex
%    └─ em_electromagnetism/.../ps_em_cb_01_q.tex

% 相対パス: ../university_exam/physics-standard/em_electromagnetism/.../ps_em_cb_01_q.tex
\subfile{../university_exam/physics-standard/em_electromagnetism/circuit-basics/01_kirchhoff/ps_em_cb_01_q.tex}
```

---

## 付録: コマンドリファレンス

### 子ファイルの基本テンプレート

```tex
% ps_em_cb_01_q.tex
\documentclass[../../../ps_q.tex]{subfiles}

\begin{document}

\subsection{問題タイトル}

問題文...

\begin{enumerate}
    \item 選択肢1
    \item 選択肢2
\end{enumerate}

\includegraphics{\subfix{fig_em_cb_01/fig_em_cb_01_01_q.pdf}}

\end{document}
```

### 親ファイルの基本テンプレート

```tex
% ps_em_cb_q.tex
\documentclass[../../ps_q.tex]{subfiles}

\begin{document}

\section{回路の基本}

\subfile{01_kirchhoff/ps_em_cb_01_q.tex}
\subfile{02_charge-conservation-1/ps_em_cb_02_q.tex}
...

\end{document}
```

### プリント親ファイルの基本テンプレート

```tex
% prnt_exam_2024_spring.tex
\documentclass[../university_exam/physics-standard/ps_q.tex]{subfiles}

\title{2024年春 物理演習プリント}

\begin{document}

\maketitle

\section{電磁気}

\subfile{../university_exam/physics-standard/em_electromagnetism/circuit-basics/01_kirchhoff/ps_em_cb_01_q.tex}

\end{document}
```

---

## 参考資料

- **LaTeX subfiles パッケージ公式**: CTAN subfiles
- **science-db README_STRUCTURE.md**: [scripts/README_STRUCTURE.md](../README_STRUCTURE.md) の「subfiles 構造」セクション
- **science-db WORKFLOW.md**: [scripts/docs/WORKFLOW.md](WORKFLOW.md) の「Git ワークフロー」セクション

---

**最終更新**: 2026年3月4日  
**管理者**: science-db チャット（Copilot）
