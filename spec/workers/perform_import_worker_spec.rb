require 'rails_helper'

describe PerformImportWorker do
  let(:import) { create(:import) }
  let(:backend_role) { create(:role, name: 'Backend Developer') }
  let(:architect_role) { create(:role, name: 'Architect') }

  subject { PerformImportWorker.new.perform(import.id) }

  it 'creates skill' do
    expect { subject }.to change { Skill.count }.by(1)
  end

  context 'after subject' do
    before { subject }

    let(:skill) { Skill.last }

    it 'links skill to roles' do
      expect(backend_role.reload.skills).to include(skill)
      expect(architect_role.reload.skills).to include(skill)
    end
  end
  
end
