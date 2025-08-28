import subprocess
import sys

def get_latest_commit_hash(repo_url: str, branch_name: str) -> str | None:
    """
    지정된 Git 저장소의 특정 브랜치에서 최신 커밋 해시를 가져옵니다.

    Args:
        repo_url: 대상 Git 저장소의 URL입니다.
        branch_name: 커밋 해시를 가져올 브랜치의 이름입니다.

    Returns:
        최신 커밋 해시 문자열을 반환하거나, 실패 시 None을 반환합니다.
    """
    command = ["git", "ls-remote", repo_url, branch_name]

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True,
            encoding='utf-8'
        )

        output = result.stdout.strip()

        if not output:
            print(f"Error: Branch '{branch_name}' not found or repository is empty.", file=sys.stderr)
            return None

        commit_hash = output.split()[0]
        return commit_hash

    except FileNotFoundError:
        print("Error: 'git' command not found. Is Git installed on your system?", file=sys.stderr)
        return None
    except subprocess.CalledProcessError as e:
        print(f"Error executing git command for {repo_url}", file=sys.stderr)
        print(f"Stderr: {e.stderr.strip()}", file=sys.stderr)
        return None
    except IndexError:
        print(f"Error: Could not parse the output from git ls-remote.", file=sys.stderr)
        print(f"Raw output: {result.stdout}", file=sys.stderr)
        return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: python {sys.argv[0]} <repository_name>")
        print(f"Example: python {sys.argv[0]} vision-backend")
        sys.exit(1)

    repo_name = sys.argv[1]
    REPO_URL = f"https://github.com/KimSiHo/{repo_name}.git"
    BRANCH = "master"

    # print(f"Fetching latest commit for {REPO_URL} on branch '{BRANCH}'...")

    latest_hash = get_latest_commit_hash(REPO_URL, BRANCH)

    if latest_hash:
        print(latest_hash)
    else:
        sys.exit(1)
