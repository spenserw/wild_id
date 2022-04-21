require "application_system_test_case"

class BirdFamiliesTest < ApplicationSystemTestCase
  setup do
    @bird_family = bird_families(:one)
  end

  test "visiting the index" do
    visit bird_families_url
    assert_selector "h1", text: "Bird families"
  end

  test "should create bird family" do
    visit bird_families_url
    click_on "New bird family"

    click_on "Create Bird family"

    assert_text "Bird family was successfully created"
    click_on "Back"
  end

  test "should update Bird family" do
    visit bird_family_url(@bird_family)
    click_on "Edit this bird family", match: :first

    click_on "Update Bird family"

    assert_text "Bird family was successfully updated"
    click_on "Back"
  end

  test "should destroy Bird family" do
    visit bird_family_url(@bird_family)
    click_on "Destroy this bird family", match: :first

    assert_text "Bird family was successfully destroyed"
  end
end
