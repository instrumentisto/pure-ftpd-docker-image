#!/usr/bin/env bats


@test "post_push hook is up-to-date" {
  run sh -c "cat Makefile | grep 'TAGS ?= ' | cut -d ' ' -f 3"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  expected="$output"

  run sh -c "cat hooks/post_push | grep 'for tag in' \
                                 | cut -d '{' -f 2 \
                                 | cut -d '}' -f 1"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  actual="$output"

  [ "$actual" = "$expected" ]
}


@test "pure-ftpd is installed" {
  run docker run --rm --entrypoint sh $IMAGE -c 'which pure-ftpd'
  [ "$status" -eq 0 ]
}

@test "pure-ftpd runs ok" {
  run docker run --rm --entrypoint sh $IMAGE -c 'pure-ftpd --help'
  [ "$status" -eq 0 ]
}

@test "pure-ftpd has correct version" {
  run sh -c "cat Makefile | grep 'VERSION ?= ' | cut -d ' ' -f 3"
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
    -v $(pwd)/test/resources/pureftpd.passwd:/etc/pureftpd.passwd:ro \
      $IMAGE test -f /etc/pureftpd.pdb
  [ "$status" -eq 0 ]
}
