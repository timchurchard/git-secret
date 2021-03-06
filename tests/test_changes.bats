#!/usr/bin/env bats

load _test_base

FILE_TO_HIDE="file_to_hide"
SECOND_FILE_TO_HIDE="second_file_to_hide"
FILE_CONTENTS="hidden content юникод"

FINGERPRINT=""


function setup {
  FINGERPRINT=$(install_fixture_full_key "$TEST_DEFAULT_USER")

  set_state_git
  set_state_secret_init
  set_state_secret_tell "$TEST_DEFAULT_USER"
  set_state_secret_add "$FILE_TO_HIDE" "$FILE_CONTENTS"
  set_state_secret_add "$SECOND_FILE_TO_HIDE" "$FILE_CONTENTS"
  set_state_secret_hide
}


function teardown {
  uninstall_fixture_full_key "$TEST_DEFAULT_USER" "$FINGERPRINT"
  unset_current_state
  rm -f "$FILE_TO_HIDE"
}


@test "run 'changes' with one file changed" {
  local password=$(test_user_password "$TEST_DEFAULT_USER")
  local new_content="new content"
  echo "$new_content" >> "$FILE_TO_HIDE"

  run git secret changes -d "$TEST_GPG_HOMEDIR" -p "$password" "$FILE_TO_HIDE"
  [ "$status" -eq 0 ]

  # Testing that output has both filename and changes:
  [[ "$output" == *"changes in $FILE_TO_HIDE"* ]]
  [[ "$output" == *"$new_content"* ]]
}


@test "run 'changes' without changes" {
  local password=$(test_user_password "$TEST_DEFAULT_USER")
  run git secret changes -d "$TEST_GPG_HOMEDIR" -p "$password"
  [ "$status" -eq 0 ]
}


@test "run 'changes' with multiple files changed" {
  local password=$(test_user_password "$TEST_DEFAULT_USER")
  local new_content="new content"
  local second_new_content="something different"
  echo "$new_content" >> "$FILE_TO_HIDE"
  echo "$second_new_content" >> "$SECOND_FILE_TO_HIDE"

  run git secret changes -d "$TEST_GPG_HOMEDIR" -p "$password"
  [ "$status" -eq 0 ]

  # Testing that output has both filename and changes:
  [[ "$output" == *"changes in $FILE_TO_HIDE"* ]]
  [[ "$output" == *"$new_content"* ]]

  [[ "$output" == *"changes in $SECOND_FILE_TO_HIDE"* ]]
  [[ "$output" == *"$second_file_to_hide"* ]]
}
