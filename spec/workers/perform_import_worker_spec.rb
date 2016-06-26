require "rails_helper"

describe PerformImportWorker do
  let(:import) { create(:import) }
  let!(:backend_role) { create(:role, name: "Backend Developer") }
  let!(:architect_role) { create(:role, name: "Architect") }

  subject { PerformImportWorker.new.perform(import.id) }

  it "marks import as processed" do
    expect { subject }.to change { import.reload.processed? }.from(false).to(true)
  end

  context "skill does not exist" do
    it "creates skill" do
      expect { subject }.to change { Skill.count }.by(1)
    end

    context "after subject" do
      before { subject }

      let(:skill) { Skill.last }

      it "links skill to roles" do
        expect(backend_role.reload.skills).to include(skill)
        expect(architect_role.reload.skills).to include(skill)
      end
    end
  end

  context "skill exists" do
    let!(:skill) { create(:skill, title: "Gruby", original_row: 1) }
    let!(:role_skill) { create(:role_skill, role: architect_role, skill: skill, cat: :cat1) }

    it "updates title" do
      expect { subject }.to change { skill.reload.title }.from("Gruby").to("Ruby")
    end

    it "moves current role to correct slot" do
      expect { subject }.to change { role_skill.reload.cat }.from("cat1").to("cat2")
    end

    it "links skill to new role in correct slot" do
      expect { subject }.
        to change { skill.role_skills.reload.where(role: backend_role, cat: "cat1").count }.
        from(0).to(1)
    end
  end
end
