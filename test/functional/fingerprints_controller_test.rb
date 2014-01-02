require 'test_helper'

class FingerprintsControllerTest < ActionController::TestCase
  setup do
    @fingerprint = fingerprints(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fingerprints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fingerprint" do
    assert_difference('Fingerprint.count') do
      post :create, fingerprint: { card_no: @fingerprint.card_no, dept_name: @fingerprint.dept_name, employee_name: @fingerprint.employee_name, employee_no: @fingerprint.employee_no, file_name: @fingerprint.file_name, fp_time: @fingerprint.fp_time, machine: @fingerprint.machine, no: @fingerprint.no, pattern: @fingerprint.pattern }
    end

    assert_redirected_to fingerprint_path(assigns(:fingerprint))
  end

  test "should show fingerprint" do
    get :show, id: @fingerprint
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fingerprint
    assert_response :success
  end

  test "should update fingerprint" do
    put :update, id: @fingerprint, fingerprint: { card_no: @fingerprint.card_no, dept_name: @fingerprint.dept_name, employee_name: @fingerprint.employee_name, employee_no: @fingerprint.employee_no, file_name: @fingerprint.file_name, fp_time: @fingerprint.fp_time, machine: @fingerprint.machine, no: @fingerprint.no, pattern: @fingerprint.pattern }
    assert_redirected_to fingerprint_path(assigns(:fingerprint))
  end

  test "should destroy fingerprint" do
    assert_difference('Fingerprint.count', -1) do
      delete :destroy, id: @fingerprint
    end

    assert_redirected_to fingerprints_path
  end
end
