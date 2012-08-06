-- Node.lua
-- Nodes can have a parent. They have a position relative to their parent.
-- If their parent is nil, their positions are global.
-- Though a Node may be the parent of another Node, the parent doesn't know it.

Node = Class(function(self, parent, p)
	self.parent = parent
	self.p = p or vector(0,0)
end)

function Node:globalPos()
	-- get the global position of this node
	local p = self.p
	if self.parent then
		p = p + self.parent:globalPos()
	end
	return p
end