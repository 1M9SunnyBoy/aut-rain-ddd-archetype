"""Exercise generated scripts with fake tools only; never run real Docker or builds."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def check_app_scripts(project):
    pwsh = shutil.which('pwsh') or shutil.which('powershell')
    git = shutil.which('git')
    bash = Path(git).parents[1] / 'bin/bash.exe' if os.name == 'nt' and git else None
    bash = str(bash) if bash and bash.is_file() else shutil.which('bash')
    if not pwsh or not bash:
        raise RuntimeError('Script verification requires PowerShell and Bash (Git Bash on Windows)')
    with tempfile.TemporaryDirectory(prefix='app scripts with spaces ') as temp:
        root = Path(temp)
        ops = root / 'docs/dev-ops'
        shutil.copytree(project / 'docs/dev-ops', ops)
        module = root / 'app-backend/sample-service-app/target'
        module.mkdir(parents=True)
        (module / 'sample-service-app.jar').write_bytes(b'test only')
        (root / 'web/dist').mkdir(parents=True)
        (root / 'web/dist/index.html').write_text('test only')
        (ops / 'app/.env').write_text('test only')
        log = root / 'calls.log'
        harness = root / 'harness.ps1'
        harness.write_text(r'''
param([string]$Script)
$ErrorActionPreference = 'Stop'
function Record-Mock {
    param([string]$Tool, [object[]]$Values)
    Add-Content -LiteralPath $env:MOCK_LOG -Value (ConvertTo-Json -Compress -InputObject (@($Tool) + $Values))
    $global:LASTEXITCODE = 0
    $Match = switch ($env:MOCK_FAIL) {
        'mvn' { $Tool -eq 'mvn' }
        'config' { $Tool -eq 'docker' -and $Values -contains 'config' }
        'image' { $Tool -eq 'docker' -and $Values -contains 'inspect' }
        'up' { $Tool -eq 'docker' -and $Values -contains 'up' }
        default { $false }
    }
    if ($Match) { $global:LASTEXITCODE = 9 }
    if ($Tool -eq 'node') { 'v22.22.0' }
}
function docker { Record-Mock 'docker' $args }
function mvn { Record-Mock 'mvn' $args }
function node { Record-Mock 'node' $args }
function corepack { Record-Mock 'corepack' $args }
function java { Record-Mock 'java' $args }
$Original = (Get-Location).Path
$env:IMAGE_TAG = 'previous'
$Failed = $false
try { & $Script -ImageTag 'test-tag' } catch { $Failed = $true }
if ((Get-Location).Path -ne $Original -or $env:IMAGE_TAG -ne 'previous') { exit 21 }
if ($Failed) { exit 9 }
''', encoding='utf-8')
        bin_dir = root / 'fake-bin'
        bin_dir.mkdir()
        mock = r'''#!/usr/bin/env bash
tool="$(basename "$0")"
printf '%s' "$tool" >> "$MOCK_LOG"
printf '\t%s' "$@" >> "$MOCK_LOG"
printf '\n' >> "$MOCK_LOG"
case "$MOCK_FAIL:$tool:$*" in
  mvn:mvn:*|config:docker:*config*|image:docker:*inspect*|up:docker:*" up "*) exit 9;;
esac
if [[ "$tool" == node ]]; then echo v22.22.0; fi
'''
        for name in ('docker', 'mvn', 'node', 'corepack', 'java'):
            path = bin_dir / name
            path.write_text(mock, encoding='utf-8', newline='\n')
            path.chmod(0o755)
        for sh in (ops / 'app/sh').glob('*.sh'):
            assert b'\r' not in sh.read_bytes(), sh
            subprocess.run([bash, '-n', str(sh)], check=True, capture_output=True)
        for language in ('psw', 'sh'):
            for action, failure in [('start', ''), ('stop', ''), ('build', ''),
                                    ('start', 'config'), ('start', 'image'),
                                    ('start', 'up'), ('build', 'mvn')]:
                log.write_text('')
                env = {**os.environ, 'MOCK_LOG': str(log), 'MOCK_FAIL': failure}
                if language == 'psw':
                    args = [pwsh, '-NoProfile', '-File', str(harness),
                            str(ops / 'app/psw' / (action + '.ps1'))]
                else:
                    env['PATH'] = str(bin_dir) + os.pathsep + env['PATH']
                    args = [bash, str(ops / 'app/sh' / (action + '.sh')), 'test-tag']
                result = subprocess.run(args, env=env, cwd=root.parent,
                                        capture_output=True, text=True)
                assert (result.returncode != 0) == bool(failure), (language, action, failure, result.stdout, result.stderr)
                calls = [json.loads(line.lstrip('\ufeff')) if language == 'psw' else line.split('\t')
                         for line in log.read_text(encoding='utf-8-sig').splitlines()]
                assert calls, (language, action)
                ups = [c for c in calls if 'up' in c]
                if action == 'stop':
                    assert calls[-1][-3:] == ['stop', 'nginx', 'app']
                    assert not ups and not any('down' in c or 'rm' in c for c in calls)
                elif action == 'start':
                    if not failure:
                        assert [c[-1] for c in ups] == ['app', 'nginx']
                    elif failure == 'up':
                        assert len(ups) == 1 and ups[0][-1] == 'app'
                    else:
                        assert not ups
                    for call in ups:
                        assert all(flag in call for flag in ('--no-deps', '--no-build', '--force-recreate', '--wait'))
                        assert call[call.index('--pull') + 1] == 'never'
                elif action == 'build':
                    builds = [c for c in calls if c[:2] == ['docker', 'build']]
                    assert len(builds) == (0 if failure else 2), calls
                    if failure:
                        assert not any(c[0] == 'corepack' for c in calls)
                    else:
                        assert 'sample-service/app:test-tag' in builds[0]
                        assert 'sample-service/web:test-tag' in builds[1]
                        assert not ups
        print('Bash/PowerShell start, stop, build and failure boundaries passed with mock tools (no services).', flush=True)
