# gh issue / PR を nvim + fzf で作るヘルパー
#
# 使い方: リポジトリ内で ghic (issue) / ghprc (PR)。追加引数は gh にそのまま渡る
#         (例: ghic --repo owner/repo)
# 書式:   nvim が開くので 1 行目の「# 」に続けてタイトル、それ以降に本文を書く。
#         本文はそのまま --body-file で渡るので markdown が壊れない
#         (インライン --body だとバッククォート等がシェルに解釈される事故が起きる)。
# 下書き: ~/.local/state/gh-drafts/ に置かれ、中止・投稿失敗時はそのまま残る。
#         書き直すときは ghic <下書きパス> のようにファイルを渡すと続きから編集できる。

_GH_DRAFT_DIR="$HOME/.local/state/gh-drafts"

# 下書きを編集してタイトルを標準出力に返す。タイトル空なら失敗
_gh_draft_edit() {
  local draft="$1"
  nvim '+startinsert!' "$draft" </dev/tty >/dev/tty
  awk '/^# /{sub(/^# /,""); print; exit}' "$draft" | grep -E '\S'
}

# 下書きからタイトル行を除いた本文を標準出力に返す(先頭の空行は落とす)
_gh_draft_body() {
  awk 'f && (p || NF) {p=1; print} !f && /^# /{f=1}' "$1"
}

# ラベルを fzf で複数選択してカンマ結合で返す(リポジトリ外・Esc なら空)
_gh_pick_labels() {
  gh label list --limit 100 --json name,description \
    --jq '.[] | .name + "\t" + .description' 2>/dev/null |
    fzf -m --delimiter='\t' --prompt='label> ' \
      --header='ラベル選択: Tab で複数、Esc でラベルなし' |
    cut -f1 | paste -sd, -
}

# $1: issue|pr、残り: 下書きパス(任意) + gh へ渡す追加引数
_gh_create_with_draft() {
  local kind="$1" draft title labels
  shift
  mkdir -p "$_GH_DRAFT_DIR"
  if [[ -f "${1:-}" ]]; then
    draft="$1"
    shift
  else
    draft="$_GH_DRAFT_DIR/$kind-$(date +%Y%m%d-%H%M%S).md"
    printf '# \n\n' > "$draft"
  fi
  if ! title=$(_gh_draft_edit "$draft"); then
    echo "タイトル(先頭の '# ' 行)が空なので中止。下書き: $draft" >&2
    return 1
  fi
  local bodyfile
  bodyfile=$(mktemp "${TMPDIR:-/tmp}/gh-body-XXXXXX.md") || return 1
  _gh_draft_body "$draft" > "$bodyfile"
  labels=$(_gh_pick_labels)
  local -a args
  args=(--title "$title" --body-file "$bodyfile")
  [[ -n "$labels" ]] && args+=(--label "$labels")
  if gh "$kind" create "${args[@]}" "$@"; then
    rm -f "$bodyfile" "$draft"
  else
    rm -f "$bodyfile"
    echo "投稿に失敗。下書きは残してある: $draft" >&2
    return 1
  fi
}

ghic() { _gh_create_with_draft issue "$@" }
ghprc() { _gh_create_with_draft pr "$@" }
