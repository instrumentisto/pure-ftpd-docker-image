#!/usr/bin/env bats


@test "pure-ftpd is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'which pure-ftpd'
  [ "$status" -eq 0 ]
}

@test "pure-ftpd runs ok" {
  run docker run --rm --entrypoint sh $IMAGE -c 'pure-ftpd --help'
  [ "$status" -eq 0 ]
}

@test "pure-ftpd has correct version" {
  run sh -c "cat Dockerfile | grep 'ARG pure_ftpd_ver=' | cut -d '=' -f2"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  expected="$output"

  run docker run --rm --entrypoint sh $IMAGE -c \
    "pure-ftpd --help | head -1 | cut -d ' ' -f 2"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  actual="$output"

  [ "$actual" = "v$expected" ]
}


@test "pure-pw is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'which pure-pw'
  [ "$status" -eq 0 ]
}

@test "pure-pw runs ok" {
  run docker run --rm --entrypoint sh $IMAGE -c 'pure-pw --help'
  [ "$status" -eq 0 ]
}


@test "PURE_PASSWDFILE is converted to PURE_DBFILE on container start" {
  run docker run --rm \
    -v $(pwd)/tests/resources/pureftpd.passwd:/etc/pureftpd.passwd:ro \
      $IMAGE test -f /etc/pureftpd.pdb
  [ "$status" -eq 0 ]
}
