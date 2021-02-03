require 'rails_helper'

RSpec.describe 'ログインとログアウト', type: :system do

  let!(:user) { User.create(
    email: 'test@example.com',
    password: 'password'
  )}


  it '有効な入力でログインできる' do
    visit new_user_session_path
    fill_in 'Eメール', with: 'test@example.com'
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'
    expect(page).to have_content 'ログインしました'
  end

  it 'ログアウトできる'  do
    visit new_user_session_path
    fill_in 'Eメール', with: 'test@example.com'
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'
    expect(page).to have_link 'ログアウト'
    click_link 'ログアウト'
    expect(page).to have_link 'ログイン'
  end

  it '無効なメールアドレスでログインできない' do
    visit new_user_session_path
    fill_in 'Eメール', with: ''
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'
    expect(page).to have_content 'Eメールまたはパスワードが違います'
  end

  it '無効なパスワードでログインできない' do
    visit new_user_session_path
    fill_in 'Eメール', with: 'test@example.com'
    fill_in 'パスワード', with: ''
    click_button 'ログイン'
    expect(page).to have_content 'Eメールまたはパスワードが違います'
  end
end

RSpec.describe 'サインアップ', type: :system do
  before do
    User.create!(email: 'test@example.com', password: 'password')
  end

  it '有効な入力でサインアップに成功する' do
    visit new_user_registration_path
    expect {
      fill_in 'Eメール', with: 'success@example.com'
      fill_in 'パスワード', with: 'password'
      fill_in 'パスワード（確認用）', with: 'password'
      click_button 'サインアップ'
  }.to change(User, :count).by(1)
  end

  it '重複したメールアドレスでサインアップに失敗する' do
    visit new_user_registration_path
    expect {
      fill_in 'Eメール', with: 'test@example.com'
      fill_in 'パスワード', with: 'password'
      fill_in 'パスワード（確認用）', with: 'password'
      click_button 'サインアップ'
  }.to_not change{User.count}
  end
end

RSpec.describe 'ログインしていないユーザー', type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:post) {FactoryBot.create(:post, user_id: user.id)}

  describe 'ユーザー詳細ページ' do
    before do
      visit profile_show_user_path(user)
    end

    it 'ユーザー詳細ページへアクセスできる' do
      expect(page).to have_content user.name
    end

    it '他のユーザーページでそのユーザーの投稿一覧を見ることができる' do
      expect(page).to have_selector 'div', id: user.name + 'の投稿'
    end

    it 'ユーザーのアバターが表示される' do
      expect(page).to have_selector '#user_avatar'
    end

    it 'ユーザー編集ページへのリンクが表示されない' do
      expect(page).to_not have_selector 'a', text: 'ユーザー情報の編集'
    end
  end
end

RSpec.describe 'ログインしているユーザー', type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:post) { FactoryBot.create(:post, user_id: user.id) }

  before do
    sign_in user
  end

  describe 'ユーザー詳細ページ' do
    before do
      visit profile_show_user_path(user)
    end

    it '自身の投稿一覧が表示される' do
      expect(page).to have_selector 'div', id: user.name + 'の投稿'
    end

    it 'ユーザーのアバターが表示される' do
      expect(page).to have_selector '#user_avatar'
    end

    it 'ユーザー編集ページへのリンクが表示される' do
      expect(page).to have_selector 'a', text: 'ユーザー情報の編集'
    end
  end

  describe 'プロフィール変更ページ' do
    before do
      visit profile_edit_user_path(user)
    end

    it 'アクセスできる' do
      expect(page).to have_content 'プロフィールの変更'
    end

    it 'ユーザー情報に関する設定へのリンクがある' do
      expect(page).to have_link 'ユーザー情報に関する設定'
    end

    it 'ニックネームの変更フォームがある' do
      expect(page).to have_selector 'input[id="user_name"]'
    end

    it 'アバター変更するファイル選択欄がある' do
      expect(page).to have_content 'ファイル選択'
    end

    it '現在のユーザーのアバターが表示されている' do
      expect(page).to have_selector 'img[id="user_avatar"]'
    end

    it '変更を反映するボタンをクリックした後ユーザー詳細ページにリダイレクトされる' do
      click_on '変更を反映する'
      expect(page).to have_content user.name + 'の投稿'
    end

    it 'ユーザーのニックネームの変更が正常に反映される' do
      fill_in 'ニックネームの変更', with: 'changed_name'
      click_on '変更を反映する'
      expect(page).to have_content 'changed_nameの投稿'
    end

    it 'ユーザーのアバターの変更が正常に反映される' do
      page.attach_file('spec/fixtures/sample.jpg') do
        page.find('.custom-file').click
      end
      click_on '変更を反映する'
      expect(page).to have_selector 'img[title="sample.jpg"]'
    end

    it 'ユーザー情報に関する設定ボタンをクリックした後、ユーザー情報に関する設定ページが正しく表示される' do
      click_on 'ユーザー情報に関する設定'
      expect(page).to have_selector 'h2', text: 'ユーザー情報に関する設定'
    end
  end
end

