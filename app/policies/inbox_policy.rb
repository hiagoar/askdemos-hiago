class InboxPolicy < ApplicationPolicy
  def edit?
    record.user == user
  end

  def destroy?
    edit?
  end

  def update?
    edit?
  end
end
