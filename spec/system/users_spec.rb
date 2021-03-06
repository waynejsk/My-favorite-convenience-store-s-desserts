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
  let!(:user){ User.create!(email: 'duplicate@example.com', password: 'password')}

  before do
    visit new_user_registration_path
  end

  it '有効な入力でサインアップに成功する' do
    expect {
      fill_in 'Eメール', with: 'success@example.com'
      fill_in 'パスワード', with: 'password'
      fill_in 'パスワード（確認用）', with: 'password'
      click_button 'サインアップ'
  }.to change(User, :count).by(1)
  end

  it '重複したメールアドレスでサインアップに失敗する' do
    expect {
      fill_in 'Eメール', with: 'duplicate@example.com'
      fill_in 'パスワード', with: 'password'
      fill_in 'パスワード（確認用）', with: 'password'
      click_button 'サインアップ'
  }.to_not change{User.count}
  end

  it '登録時のニックネームが反映される' do
    fill_in 'Eメール', with: 'success@example.com'
    fill_in 'ニックネーム', with: 'テストユーザー'
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワード（確認用）', with: 'password'
    click_button 'サインアップ'
    expect(page).to have_link 'テストユーザー'
  end

  it 'かんたんログインができる' do
    visit root_path
    expect {
      click_on 'かんたんログイン'
    }.to change{User.count}.by(1)
  end
end




RSpec.describe 'ログインしていないユーザー', type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:post) {FactoryBot.create(:post, user_id: user.id)}

  describe 'ユーザー詳細ページ' do
    before do
      visit profile_show_user_path(user)
    end

    it 'アクセスできる' do
      expect(page).to have_content user.name + 'の投稿'
    end

    it '投稿一覧が表示される' do
      expect(page).to have_selector 'img[alt="sample.jpg"]'
    end

    it 'ユーザーのアバターが表示される' do
      expect(page).to have_selector '#user_avatar'
    end

    it 'ユーザー編集ページへのリンクが表示されない' do
      expect(page).to_not have_selector 'a', text: 'ユーザー情報の編集'
    end

    it 'ユーザーの自己紹介が表示される' do
      user.update(introduction: 'this is introduction')
      visit current_path
      expect(page).to have_content 'this is introduction'
    end
  end

  describe 'フォロー関連' do
    it 'フォロワー一覧へアクセスできる' do
      visit profile_show_user_path(user)
      click_on 'following-size'
      expect(page).to have_content 'さんのフォローしているユーザー'
    end

    it 'フォロー一覧ページへアクセスできる' do
      visit profile_show_user_path(user)
      click_on 'follower-size'
      expect(page).to have_content 'さんをフォローしているユーザー'
    end

    describe '一覧ページの表示' do
      let!(:user2) {create(:user)}
      let!(:user3) {create(:user)}
      let!(:post_by_user2) {create(:post, user_id: user2.id)}
      let!(:post_by_user3) {create(:post, user_id: user3.id)}

      before do
        #user3がuser2をフォローしている
        FactoryBot.create(:follow_relationship, following_id: user2.id, follower_id: user3.id)
      end
      describe 'フォロワー一覧ページ' do
        before do
          visit follower_user_path(user2)
        end

        it 'フォロワーの名前が表示される' do
          expect(page).to have_selector 'a[id="follower_name"]'
        end

        it 'フォロワーのアバターが表示される' do
          expect(page).to have_selector 'img[id="user_avatar"]'
        end

        it 'フォロワーの投稿が表示される' do
          expect(page).to have_css '#user_post'
        end
      end

      describe 'フォロー一覧ページ' do
        before do
          visit followings_user_path(user3)
        end

        it 'フォローユーザーの名前が表示される' do
          expect(page).to have_selector 'a[id="following_user_name"]'
        end

        it 'フォローユーザーのアバターが表示される' do
          expect(page).to have_selector 'img[id="user_avatar"]'
        end

        it 'フォローユーザーの投稿が表示される' do
          expect(page).to have_css '#user_post'
        end
      end
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

    it 'ユーザーの自己紹介が表示される' do
      user.update(introduction: 'this is introduction')
      visit current_path
      expect(page).to have_content 'this is introduction'
    end
  end

  describe 'プロフィール変更ページ' do
    before do
      visit profile_edit_user_path(user)
    end

    it 'アクセスできる' do
      expect(page).to have_content 'プロフィールの変更'
    end

    it 'ユーザー登録情報に関する設定へのリンクがある' do
      expect(page).to have_link 'ユーザー登録情報に関する設定'
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

    it 'ユーザー登録情報に関する設定ボタンをクリックした後、ユーザー登録情報に関する設定ページが正しく表示される' do
      click_on 'ユーザー登録情報に関する設定'
      expect(page).to have_selector 'h2', text: 'ユーザー登録情報に関する設定'
    end

    it '自己紹介編集が正常に反映される' do
      fill_in '自己紹介の編集', with: '編集された自己紹介です'
      click_on '変更を反映する'
      expect(page).to have_content '編集された自己紹介です'
    end
  end

  describe 'ユーザー登録情報に関する設定ページ' do
    before do
      visit edit_user_registration_path(user)
    end

    it 'アクセスできる' do
      expect(page).to have_selector 'h2', text: 'ユーザー登録情報に関する設定'
    end

    it '現在のEメールが表示される' do
      expect(page).to have_xpath("//input[@id='user_email'][@value='#{user.email}']")
    end

    it '更新するには現在のパスワードを入力する必要がある' do
      click_on '更新する'
      expect(page).to have_content '現在のパスワードを入力してください'
    end
  end

  describe 'フォロー関連' do
    it 'フォロワー一覧へアクセスできる' do
      visit profile_show_user_path(user)
      click_on 'following-size'
      expect(page).to have_content 'さんのフォローしているユーザー'
    end

    it 'フォロー一覧ページへアクセスできる' do
      visit profile_show_user_path(user)
      click_on 'follower-size'
      expect(page).to have_content 'さんをフォローしているユーザー'
    end

    describe '一覧ページの表示' do
      let!(:user2) {create(:user)}
      let!(:user3) {create(:user)}
      let!(:post_by_user2) {create(:post, user_id: user2.id)}
      let!(:post_by_user3) {create(:post, user_id: user3.id)}

      before do
        #user3がuser2をフォローしている
        FactoryBot.create(:follow_relationship, following_id: user2.id, follower_id: user3.id)
      end
      describe 'フォロワー一覧ページ' do
        before do
          visit follower_user_path(user2)
        end

        it 'フォロワーの名前が表示される' do
          expect(page).to have_selector 'a[id="follower_name"]'
        end

        it 'フォロワーのアバターが表示される' do
          expect(page).to have_selector 'img[id="user_avatar"]'
        end

        it 'フォロワーの投稿が表示される' do
          expect(page).to have_css '#user_post'
        end
      end

      describe 'フォロー一覧ページ' do
        before do
          visit followings_user_path(user3)
        end

        it 'フォローユーザーの名前が表示される' do
          expect(page).to have_selector 'a[id="following_user_name"]'
        end

        it 'フォローユーザーのアバターが表示される' do
          expect(page).to have_selector 'img[id="user_avatar"]'
        end

        it 'フォローユーザーの投稿が表示される' do
          expect(page).to have_css '#user_post'
        end
      end
    end

    describe 'フォロー機能' do
      let!(:user2) {create(:user)}
      before do
        visit profile_show_user_path(user2)
      end

      it 'フォロー人数が表示される' do
        expect(page).to have_selector 'a[id="following-size"]'
      end

      it 'フォロワー人数が表示される' do
        expect(page).to have_selector 'a[id="follower-size"]'
      end

      it 'フォローできる' do
        expect{
          click_on 'フォローする'
        }.to change{FollowRelationship.count}.by(1)
      end
    end

  end
end

