require "application_system_test_case"

class BirdSpeciesTest < ApplicationSystemTestCase
  setup do
    @bird_specy = bird_species(:one)
  end

  test "visiting the index" do
    visit bird_species_url
    assert_selector "h1", text: "Bird species"
  end

  test "should create bird specy" do
    visit bird_species_url
    click_on "New bird specy"

    click_on "Create Bird specy"

    assert_text "Bird specy was successfully created"
    click_on "Back"
  end

  test "should update Bird specy" do
    visit bird_specy_url(@bird_specy)
    click_on "Edit this bird specy", match: :first

    click_on "Update Bird specy"

    assert_text "Bird specy was successfully updated"
    click_on "Back"
  end

  test "should destroy Bird specy" do
    visit bird_specy_url(@bird_specy)
    click_on "Destroy this bird specy", match: :first

    assert_text "Bird specy was successfully destroyed"
  end
end
