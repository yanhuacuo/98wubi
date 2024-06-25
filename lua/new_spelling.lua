local basic = require('lib/basic')
local border = require('lib/border')
local map = basic.map
local index = basic.index
local utf8chars = basic.utf8chars
local matchstr = basic.matchstr


local function SubStringGetByteCount(str, index)
	local curByte = string.byte(str, index)
	local byteCount = 1;
	if curByte == nil then
		byteCount = 0
	elseif curByte > 0 and curByte <= 127 then
		byteCount = 1
	elseif curByte>=192 and curByte<=223 then
		byteCount = 2
	elseif curByte>=224 and curByte<=239 then
		byteCount = 3
	elseif curByte>=240 and curByte<=247 then
		byteCount = 4
	end
	return byteCount;
end

-- 获取中英混合UTF8字符串的真实字符数量
local function SubStringGetTotalIndex(str)
	local curIndex = 0;
	local i = 1;
	local lastCount = 1;
	repeat
		lastCount = SubStringGetByteCount(str, i)
		i = i + lastCount;
		curIndex = curIndex + 1;
	until(lastCount == 0);
	return curIndex - 1;
end

local function xform(input)
	if input == "" then return "" end
	input = input:gsub('%[', border_began)
	input = input:gsub('%]', border_end)
	input = input:gsub('※', ' ')
	input = input:gsub('_', ' ')
	input = input:gsub(',', '·')
	return input
end

local function subspelling(str, ...)
	local first, last = ...
	if not first then return str end
	local radicals = {}
	local s = str
	s = s:gsub('{', ' {')
	s = s:gsub('}', '} ')
	for seg in s:gmatch('%S+') do
		if seg:find('^{.+}$') then
			table.insert(radicals, seg)
		else
			for pos, code in utf8.codes(seg) do
				table.insert(radicals, utf8.char(code))
			end
		end
	end
	return table.concat{ table.unpack(radicals, first, last) }
end

local function lookup(db)
	return function (str)
		return db:lookup(str)
	end
end

local function parse_spll(str)
	local s = string.gsub(str, ',.*', '')
	return string.gsub(s, '^%[', '')
end

local function parse_encode(str)
	local s = string.gsub(str, '%[(.-),(.-),(.-),(.-)%]', '[%2]')
	return string.gsub(s, '^%[', '')
end

local function spell_phrase(s, spll_rvdb)
	local chars = utf8chars(s)
	local rvlk_results
	if #chars == 2 or #chars == 3 then
		rvlk_results = map(chars, lookup(spll_rvdb))
	else
		rvlk_results = map({chars[1], chars[2], chars[3], chars[#chars]},
				lookup(spll_rvdb))
	end
	if index(rvlk_results, '') then return '' end
	local spellings = map(rvlk_results, parse_spll)
	local sup = '◇'
	if #chars == 2 then
		return subspelling(spellings[1] .. sup, 2, 2) ..
					 subspelling(spellings[1] .. sup, 4, 4) ..
					 subspelling(spellings[2] .. sup, 2, 2) ..
					 subspelling(spellings[2] .. sup, 4, 4)
	elseif #chars == 3 then
		return subspelling(spellings[1], 2, 2) ..
					 subspelling(spellings[2], 2, 2) ..
					 subspelling(spellings[3] .. sup, 2, 2) ..
					 subspelling(spellings[3] .. sup, 4, 4)
	else
		return subspelling(spellings[1], 2, 2) ..
					 subspelling(spellings[2], 2, 2) ..
					 subspelling(spellings[3], 2, 2) ..
					 subspelling(spellings[4], 2, 2)
	end
end

local function isgb2312(cand, env)
	local ctext = cand.text
	if utf8.len(ctext) == 1 then
		local spll_raw = env.spll_rvdb:lookup(ctext)
		if spll_raw ~= '' then
			local chars =xform(spll_raw:gsub('%[(.-),(.-),(.-),(.-)%]', '[%4]'))
			if chars:find("GB2312") then return 1 else return 0 end
		else
			return 1
		end
	elseif utf8.len(ctext)>1 then
		local arr = utf8chars(ctext)
		local flag=1
		for i =1,#arr do
			local spll_raw = env.spll_rvdb:lookup(arr[i])
			if spll_raw ~= '' then
				local chars =xform(spll_raw:gsub('%[(.-),(.-),(.-),(.-)%]', '[%4]'))
				if chars:find("GBK") then return 0 else flag=1 end
			end
		end

		return flag
	end
end

local function get_en_code(s, spll_rvdb)
	local chars = utf8chars(s)
	local rvlk_results
	if #chars == 2 or #chars == 3 or #chars == 1 then
		rvlk_results = map(chars, lookup(spll_rvdb))
	else
		rvlk_results = map({chars[1], chars[2], chars[3], chars[#chars]},
				lookup(spll_rvdb))
	end
	if index(rvlk_results, '') then return '' end
	local spellings = map(rvlk_results, parse_encode)
	local sup = '◇'
	if #chars == 1 then
		return spellings[1]:gsub('[^%a]+','')
	elseif #chars == 2 then
		return spellings[1]:gsub('[^%a]+',''):sub(1,2) ..
			spellings[2]:gsub('[^%a]+',''):sub(1,2)
	elseif #chars == 3 then
		return spellings[1]:gsub('[^%a]+',''):sub(1,1) ..
			spellings[2]:gsub('[^%a]+',''):sub(1,1) ..
			spellings[3]:gsub('[^%a]+',''):sub(1,2)
	else
		return spellings[1]:gsub('[^%a]+',''):sub(1,1) ..
			spellings[2]:gsub('[^%a]+',''):sub(1,1) ..
			spellings[3]:gsub('[^%a]+',''):sub(1,1) ..
			spellings[4]:gsub('[^%a]+',''):sub(1,1)
	end
end

local function get_tricomment(cand, env)
	local ctext = cand.text
	if utf8.len(ctext) == 1 then
		local spll_raw = env.spll_rvdb:lookup(ctext)
		if spll_raw ~= '' then
			if env.engine.context:get_option("new_hide_pinyin") then
			-- return xform(spll_raw:gsub('%[(.-,.-),.+%]', '[%1]'))
				 return xform(spll_raw:gsub('%[(.-),.+%]', '[%1]'))
			else
				return xform(spll_raw:gsub('%[(.-),(.-),(.-),(.-)%]', '[%1'..' · '..'%2'..' · '..'%3]'))
			end
		end
	else
		local spelling = spell_phrase(ctext, env.spll_rvdb)
		if spelling ~= '' then
			spelling = spelling:gsub('{(.-)}', '<%1>')
			local code = env.code_rvdb:lookup(ctext)
			if code ~= '' then
				code = matchstr(code, '%S+')
				table.sort(code, function(i, j) return i:len() < j:len() end)
				code = table.concat(code, ' ')
				return border_began .. " " .. spelling .. ' · ' .. code .. " " .. border_end
			else
				return border_began .. " " .. spelling .. " " .. border_end
			end
		end
	end
	return ''
end

local function file_exists(path)
	local file = io.open(path, "rb")
	if file then file:close() end
	return file ~= nil
end

local function formatDir(path,filename)
	if path:find("\\") then
		return path .. "\\" .. filename
	elseif path:find("/") then
		return path .. "/" .. filename
	else
		return path .. "\\" .. filename
	end
end

local function get_item(filepath,item)
	local file = io.open(filepath, "rb")
	if file then
		local isexist=nil
		for line in file:lines() do
			if line:find(item) and not line:find("(%#)") then
				isexist=line:gsub('(.-):%s*(.-)', '%2')
			end
		end
		file:close()
		return isexist
	end
end

local function get_horizontal_style(filename,item)
	local shared_data_dir=rime_api.get_shared_data_dir()         -- 获取程序目录data路径
	local user_data_dir=rime_api.get_user_data_dir()         -- 获取用户目录路径
	local flag=get_item(formatDir(user_data_dir,filename),item)
	if flag~=nil then
		return flag
	else
		flag=get_item(formatDir(user_data_dir,"weasel.custom.yaml"),item)
		if flag~=nil then return flag else return get_item(formatDir(shared_data_dir,filename),item) end
	end
end

local function filter(input, env)
	local codetext=env.engine.context.input  -- 获取编码
	local script_text=env.engine.context:get_script_text()
	local hide_pinyin=env.engine.context:get_option("new_hide_pinyin")
	local schema_name=env.engine.schema.schema_name or ""
	local schema_id=env.engine.schema.schema_id or ""
	local spelling_states=env.engine.context:get_option(spelling_keyword)
	local composition = env.engine.context.composition
	local segment = composition:back()
	-- if codetext==rv_var.switch_keyword and schema_name then segment.prompt =" 〔 当前方案："..schema_name.." " .. border_end end
	-- 获取输入法常用参数
	-- env.engine.context:get_commit_text() -- filter中为获取提交词
	-- env.engine.context:get_script_text()-- 获取编码带引导符
	-- local caret_pos = env.engine.context.caret_pos          - 光标的位置通常可以理解为单字节编码长度
	-- local schema = env.engine.schema.config:get_int('menu/page_size')         -- 获取方案候选项数目参数
	-- local ascii_mode=env.engine.context:get_option("ascii_mode")  -- env.engine.context:set_option("ascii_mode", not ascii_mode)
	-- local schema_id=env.engine.schema.schema_id         -- 获取方案id
	-- local schema_name=env.engine.schema.schema_name         -- 获取方案名称
	-- local sync_dir=rime_api.get_sync_dir()         -- 获取同步资料目录
	-- local rime_version=rime_api.get_rime_version()         -- 获取rime版本号--macos无效
	-- local shared_data_dir=rime_api.get_shared_data_dir()         -- 获取程序目录data路径
	-- local user_data_dir=rime_api.get_user_data_dir()         -- 获取用户目录路径
	local horizontal=get_horizontal_style(schema_id..".custom.yaml","style/horizontal") or ""
	CandidateText={}
	-- 拆分开关开启状态才能显示字根拆分
	if spelling_states then
		for cand in input:iter() do
			if isgb2312(cand,env)==1 and env.engine.context:get_option("GB2312") or not env.engine.context:get_option("GB2312") then
				table.insert(CandidateText,cand.text)
				if cand.type == 'simplifier' and env.name_space == 'new_for_rvlk' then
					if cand.comment=="" then
						local comment = get_tricomment(cand, env)
						-- local rvlk_comment=
						yield(Candidate(spelling_keyword, cand.start, cand._end, cand.text, comment))
					end
				else
					-- 以z开头拼音反查时显示拆分逻辑
					if script_text:find("^z[a-z]*") and not script_text:find("%p$") or script_text:find("^([%/])[a-z]*") and not script_text:find("%p$") then
						-- cand.quality=10  -- 调整权值 "💡"   cand.type:'reverse_lookup'
						local add_comment=get_tricomment(cand, env)
						local code_comment=env.code_rvdb:lookup(cand.text)
						if add_comment~=nil or add_comment~="" then
							if cand.comment == "" then
								yield(Candidate(spelling_keyword, cand.start, cand._end, cand.text,add_comment))
							else
								-- 编码栏同时显示组合编码
								if cand.comment:find("(☯)") then
									segment.prompt=border_began .. "编码："..get_en_code(cand.text, env.spll_rvdb).. border_end
									yield(cand)
								else
									if utf8.len(cand.text) == 1 and code_comment and not hide_pinyin then
										yield(Candidate(spelling_keyword, cand.start, cand._end, cand.text,xform(code_comment:gsub('%[(.-),(.-),(.-),(.-)%]', '[%1'..' · '..'%2'..' · '..'%3]'))))
									else
										yield(Candidate(spelling_keyword, cand.start, cand._end, cand.text,add_comment:gsub(border_end," · ") .. cand.comment .. " " .. border_end))
									end
								end
							end
						end
					-- 以形查音状态下拆分显示逻辑
					elseif script_text:find("^([%~])[a-z]*") and not script_text:find("%p$") and env.engine.context:get_option("rvl_zhuyin") then
						local code_comment=env.code_rvdb:lookup(cand.text)
						if code_comment~="" then
							code_comment=xform(code_comment:gsub('%[(.-),(.-),(.-),(.-)%]', '[%3'..' · '..'%1]'))
							yield(Candidate("rvl_zhuyin", cand.start, cand._end, cand.text,code_comment))
						else
							yield(cand)
						end
					-- elseif script_text==rv_var.switch_keyword then
					-- 	if cand.text:find("方案") then cand.comment="〔 "..schema_name.." " .. border_end end
					-- 	yield(cand)
					else
						local add_comment = ''
						local code_comment=env.code_rvdb:lookup(cand.text)
						-- 以`号引导造词时编码栏同时显示组合编码
						if cand.comment:find("(☯)") and script_text:find("^%`*(%l+%`%l+)") then
							segment.prompt=border_began .. "编码："..get_en_code(cand.text, env.spll_rvdb).. border_end
						end
						if cand.type == 'punct' then
							add_comment = xform(code_comment:gsub('%[(.-),(.-),(.-),(.-)%]', '[%1'..' · '..'%2'..' · '..'%3]'))
						elseif cand.type ~= 'sentence' then
							add_comment = get_tricomment(cand, env)
						end
						if add_comment ~= '' then
							if cand.comment=="" then cand.comment = add_comment .. cand.comment end
						end
						-- 逐码提示编码提示加拆分显示
						if cand.comment:find("^[%~][a-zA-Z0-9]") then
							add_comment = get_tricomment(cand, env)
							-- yield(Candidate(spelling_keyword, cand.start, cand._end, cand.text,add_comment:gsub(border_end,"  ") .. cand.comment .. " " .. border_end))
							yield(Candidate(spelling_keyword, cand.start, cand._end, cand.text,add_comment:gsub(border_end,"").. border_end))
						else
							yield(cand)
						end
					end
				end
			end
		end
	else
		-- 在拆分开关关闭状态下如果没有匹配到编码自动以字根组合补全「拼音反查编码是否能匹配到取决于你当前词库是否存在那个编码，强行组合编码没意义反而显示拆分能起到学习作用
		if script_text:find("^z") then
			for cand in input:iter() do
				if isgb2312(cand,env)==1 and env.engine.context:get_option("GB2312") or not env.engine.context:get_option("GB2312") then
					table.insert(CandidateText,cand.text)
					local add_comment=get_tricomment(cand, env)
					local code_comment=env.code_rvdb:lookup(cand.text)
					if cand.comment=="" then
						if add_comment~=nil or add_comment~="" then
							cand.comment = add_comment
						end
					elseif not horizontal:find("true") then
						if add_comment~=nil or add_comment~="" then
							if utf8.len(cand.text) == 1 and code_comment and not hide_pinyin then
								cand.comment = xform(code_comment:gsub('%[(.-),(.-),(.-),(.-)%]', '[%1'..' · '..'%2'..' · '..'%3]'))
							elseif utf8.len(cand.text) == 1 and code_comment and hide_pinyin then
								cand.comment = xform(code_comment:gsub('%[(.-),(.-),(.-),(.-)%]', '[%1'..' · '..'%2]'))
							else
								cand.comment = add_comment:gsub(border_end," · ") .. cand.comment .. " " .. border_end
							end
						end
					else
						if cand.comment:find("%s") then cand.comment=" "..cand.comment:gsub("%s+"," · ") else cand.comment=" "..cand.comment end
					end
					yield(cand)
				end
			end
		-- 在分开开关关闭状态下以字根拆分补全没有匹配到的选项
		elseif script_text:find("^([%~])[a-z]*") and not script_text:find("%p$") and env.engine.context:get_option("rvl_zhuyin") then
			for cand in input:iter() do
				if isgb2312(cand,env)==1 and env.engine.context:get_option("GB2312") or not env.engine.context:get_option("GB2312") then
					table.insert(CandidateText,cand.text)
					local code_comment=env.code_rvdb:lookup(cand.text)
					if code_comment~="" then
						code_comment=xform(code_comment:gsub('%[(.-),(.-),(.-),(.-)%]', '%3')):gsub("^%s+",""):gsub("%s+$","")
						if code_comment:find("%s") then code_comment=code_comment:gsub("%s+"," · ") end
						yield(Candidate("zhuyin_rvlk", cand.start, cand._end, cand.text," "..code_comment))
					end
				end
			end
		else
			for cand in input:iter() do
				if isgb2312(cand,env)==1 and env.engine.context:get_option("GB2312") or not env.engine.context:get_option("GB2312") then
					table.insert(CandidateText,cand.text)
					-- if script_text==rv_var.switch_keyword then
					-- 	if cand.text:find("方案") then cand.comment="〔 "..schema_name.." " .. border_end end
					-- end
					if cand.comment:find("(☯)") and script_text:find("^%`*(%l+%`%l+)") then
						segment.prompt =border_began .. "编码："..get_en_code(cand.text, env.spll_rvdb).. border_end
					end
					yield(cand)
				end
			end
		end
	end
end

local function init(env)
	local config = env.engine.schema.config
	page_size = env.engine.schema.page_size
	local spll_rvdb = config:get_string('lua_reverse_db/spelling')
	local code_rvdb = config:get_string('lua_reverse_db/code')
	local abc_extags_size = config:get_list_size('abc_segmentor/extra_tags')
	env.spll_rvdb = ReverseDb('build/' .. spll_rvdb .. '.reverse.bin')
	env.code_rvdb = ReverseDb('build/' .. code_rvdb .. '.reverse.bin')
	env.is_mixtyping = abc_extags_size > 0
end

return { init = init, func = filter }



