class RPXIdentifier < ActiveRecord::Base
	validates_presence_of :identifier
	validates_uniqueness_of :identifier
end
