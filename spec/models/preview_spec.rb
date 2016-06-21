# == Schema Information
#
# Table name: previews
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  markdown   :text             not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe Preview, type: :model do
  describe "schema" do
    it { should have_db_column(:body).of_type(:text).with_options(null: false) }
    it { should have_db_column(:markdown).of_type(:text).with_options(null: false) }
    it { should have_db_column(:user_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should have_many(:preview_user_mentions) }
  end

  describe "validations" do
    it { should validate_presence_of :body }
    it { should validate_presence_of :markdown }
    it { should validate_presence_of :user }
  end

  describe "preview user mentions" do
    context "when updating a preview" do
      it "creates mentions only for existing users" do
        real_user = create(:user, username: "joshsmith")

        preview = build(:preview, markdown: "Hello @joshsmith and @someone_who_doesnt_exist")

        preview.save
        mentions = preview.preview_user_mentions

        expect(mentions.count).to eq 1
        expect(mentions.first.user).to eq real_user
      end

      context "when usernames contain underscores" do
        it "creates mentions and not <em> tags" do
          underscored_user = create(:user, username: "a_real_username")

          preview = build(:preview, markdown: "Hello @a_real_username and @not_a_real_username")
          preview.save
          mentions = preview.preview_user_mentions

          expect(mentions.count).to eq 1
          expect(mentions.first.user).to eq underscored_user
        end
      end
    end
  end
end
