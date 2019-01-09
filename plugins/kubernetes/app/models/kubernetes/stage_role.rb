# frozen_string_literal: true

module Kubernetes
  class StageRole < ActiveRecord::Base
    self.table_name = 'kubernetes_stage_roles'
  end
end
