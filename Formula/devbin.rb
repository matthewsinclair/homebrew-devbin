# devbin's Homebrew formula, kept as a TEMPLATE in devbin's own tree, outside
# the set a publish copies. It is never installed from this file:
# `bin/devbin formula render <tag> <out>` writes the formula for a release tag,
# reading the tag's commit from git, and `bin/devbin formula publish` renders
# the newest release into the tap and pushes it. The tag and the revision below
# are placeholders that render fills, exactly one of each.
#
# NOBODY TYPES A TAG OR A COMMIT INTO THIS FORMULA. brew checks out the tag at
# install and stops when its commit is not the revision, so a wrong revision
# fails every install; the offline `brew audit` accepts any 40 hex digits, so it
# would not have caught one.
class Devbin < Formula
  desc "Dev launcher framework that projects vendor as bin/devbin"
  homepage "https://github.com/matthewsinclair/devbin"
  # SSH WHILE THE REPOSITORY IS PRIVATE. Homebrew fetches inside a sandbox that
  # denies ~/Library/Keychains, so an https fetch of a private repository finds
  # no credential unless every machine sets up `gh auth setup-git` and
  # HOMEBREW_GITHUB_API_TOKEN, where ssh goes through the agent. The scp-like
  # form, git@github.com:<owner>/<repo>.git, is not a URI and brew refuses it,
  # so the url names its scheme. Once the repository is public this line
  # becomes https://github.com/matthewsinclair/devbin.git, and the formula then
  # installs for anyone.
  url "ssh://git@github.com/matthewsinclair/devbin.git",
      tag:      "v0.1.12",
      revision: "8378d7d7fc9b2e6e98621a9f4e82184dfa56ec3d"
  license :cannot_represent

  # devbin refuses macOS's own bash, 3.2, and runs on bash 5 or later. Linux
  # ships one. What a single verb needs beyond that, `bin/devbin doctor` reports
  # in each project; nothing else is installed here.
  on_macos do
    depends_on "bash"
  end

  def install
    # devbin's own publish, run from the tag's checkout: it refuses a tree that
    # is not clean, copies the runtime git names, writes the manifest with the
    # commit and every commit before it, and records that Homebrew owns this
    # install, so devbin's own install and upgrade refuse to write into it.
    system "bin/devbin", "install", "--prefix", libexec, "--managed-by", "brew"
    # The launcher finds its runtime from its own resolved path, so bin/ needs
    # only a link.
    bin.install_symlink libexec/"bin/devbin"
  end

  def caveats
    <<~EOS
      A project vendors devbin from this install:
        devbin install --into <project>
      and the project's bin/devbin upgrade finds it again at
        #{opt_libexec}
      through HOMEBREW_PREFIX, which `brew shellenv` exports, unless
      DEVBIN_INSTALL_PREFIX or the machine pointer ($XDG_DATA_HOME/devbin/home,
      by default ~/.local/share/devbin/home) names another install.
      bin/devbin doctor, run in a project, says which install it reads and why.

      devbin's own install and upgrade refuse to write into this install.
      Update it with:
        brew upgrade devbin
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/devbin --version")
  end
end
