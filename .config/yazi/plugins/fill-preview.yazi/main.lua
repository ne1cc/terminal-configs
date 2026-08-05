--- @since 26.1.22
---
--- Always render image previews at the full size of the preview pane.
---
--- Yazi's built-in image previewer only ever downscales, so an image smaller
--- than the pane is drawn at its native size. This previewer uses the pane
--- itself as the base size and lets ImageMagick scale up to meet it, so every
--- photo fills the available area.
---
--- Adapted from yazi-rs/plugins:zoom (MIT). Level 0 = fill the pane, negative
--- levels shrink it in 10% steps; there is nothing above 0 because 0 is
--- already as large as the pane can show.

local MIN_LEVEL, MAX_LEVEL = -9, 0

-- Yazi's `preview.image_filter` names mapped onto ImageMagick's.
local FILTERS = {
	nearest = "Point",
	triangle = "Triangle",
	["catmull-rom"] = "Catrom",
	gaussian = "Gaussian",
	lanczos3 = "Lanczos",
}

local get = ya.sync(function(st, url) return st.last == url and st.level end)

local save = ya.sync(function(st, url, new)
	local h = cx.active.current.hovered
	if h and h.url == url then
		st.last, st.level = url, new
		return true
	end
end)

local lock = ya.sync(function(st, url, old, new)
	if st.last == url and st.level == old then
		st.level = new
		return true
	end
end)

local move = ya.sync(function(st)
	local h = cx.active.current.hovered
	if not h then
		return
	end

	if st.last ~= h.url then
		st.last, st.level = Url(h.url), 0
	end

	return { url = h.url, level = st.level }
end)

-- Records the newest temp file and hands back the one it replaced.
local sweep = ya.sync(function(st, tmp)
	local old = st.tmp
	st.tmp = tmp
	return old
end)

local function end_(job, err)
	if not job.old_level then
		ya.preview_widget(job, err and ui.Text(err):area(job.area):wrap(ui.Wrap.YES))
	elseif err then
		ya.notify { title = "Fill preview", content = tostring(err), timeout = 5, level = "error" }
	end
end

-- Pixel size of the preview pane, capped by `preview.max_width`/`max_height`.
local function canvas(area)
	local cw, ch = rt.term.cell_size()
	if not cw then
		return rt.preview.max_width, rt.preview.max_height
	end

	return math.min(rt.preview.max_width, math.floor(area.w * cw)),
		math.min(rt.preview.max_height, math.floor(area.h * ch))
end

local function peek(_, job)
	local url = job.file.url
	local info, err = ya.image_info(url)
	if not info then
		return end_(job, Err("Failed to get image info: %s", err))
	end

	local level =
		ya.clamp(MIN_LEVEL, job.new_level or get(Url(url)) or tonumber(job.args[1]) or 0, MAX_LEVEL)
	local sync = function()
		if job.old_level then
			return lock(url, job.old_level, level)
		else
			return save(url, level)
		end
	end

	-- The pane is the base size, not the image, so smaller images scale *up*.
	local max_w, max_h = canvas(job.area)
	local new_w = math.max(1, math.floor(max_w * (1 + level * 0.1)))
	local new_h = math.max(1, math.floor(max_h * (1 + level * 0.1)))

	local tmp = os.tmpname()
	-- WEBP keeps alpha (JPEG would black out transparent screenshots) and
	-- `method=0` is its fastest encoder, which matters at these sizes.
	-- stylua: ignore
	local output, err = Command("magick"):arg {
		tostring(job.file.path),
		"-auto-orient", "-strip",
		"-filter", FILTERS[rt.preview.image_filter] or "Triangle",
		"-resize", string.format("%dx%d", new_w, new_h),
		"-quality", rt.preview.image_quality,
		"-define", "webp:method=0",
		string.format("WEBP:%s", tmp),
	}:output()

	-- Every hover writes a temp file, so drop the *previous* one now that it is
	-- no longer on screen. Sweeping the previous rather than the current file
	-- keeps whatever is being displayed on disk, whichever adapter is in use.
	local stale = sweep(tmp)
	if stale then
		fs.remove("file", Url(stale))
	end

	if not output then
		end_(job, Err("Failed to start `magick`, error: %s", err))
	elseif not output.status.success then
		end_(job, Err("`magick` exited with error code %s: %s", output.status.code, output.stderr))
	elseif sync() then
		ya.image_show(Url(tmp), job.area)
	end
	end_(job)
end

local function entry(self, job)
	local st = move()
	if not st then
		return
	end

	local motion = tonumber(job.args[1]) or 0
	local new = ya.clamp(MIN_LEVEL, st.level + motion, MAX_LEVEL)
	if new ~= st.level then
		peek(self, {
			area = ui.area("preview"),
			args = {},
			file = File { url = st.url, cha = Cha { mode = tonumber("100644", 8) } },
			skip = 0,
			new_level = new,
			old_level = st.level,
		})
	end
end

return { peek = peek, entry = entry }
