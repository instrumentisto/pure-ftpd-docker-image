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
