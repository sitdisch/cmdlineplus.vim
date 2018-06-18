if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
"=============================================================================
" Cmdlineplus - Marvelous possibilities!
"
" Original Version:
"	Author: LeafCage <leafcage+vim @ gmail.com>
" 	Source: https://github.com/LeafCage/cmdlineplus.vim/blob/master/autoload/cmdlineplus.vim
" Adapted Version:
" 	Author: sitdisch <sitdisch@gmx.de>
" 	Source: https://github.com/sitdisch/cmdlineplus.vim/blob/master/autoload/cmdlineplus.vim
" 
"=============================================================================
" movement functions
" casual movements
function! cmdlineplus#Motions(kind,count,return) "{{{
	" CONSIDER this movements are not included: j,k
  let l:cmdline = getcmdline()
  let l:cmdpos = getcmdpos()
	let l:count = a:count
	let l:rightline = s:_get_rightline(l:cmdline)
	let l:leftline = s:_get_leftline(l:cmdline)
	let l:lenght = strlen(l:cmdline)
	if (a:kind[0] ==# 'w')
		while l:count > 0
			let l:target = matchstrpos(l:rightline,'[^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]',0,1)
			if (l:target[1] != -1)
				if (l:target[0] =~ '\s')
					let l:target = matchstrpos(l:rightline,'\S',l:target[2],1)
					if (l:target[1] != -1)
						let l:rightline = strpart(l:rightline, l:target[1])
						let l:cmdpos = l:cmdpos + l:target[1]
						let l:count -= 1
					else
						let l:cmdpos = ""
						break
					endif
				elseif (l:target[1] == 0)
					let l:target = matchstrpos(l:rightline,'\<\|\s',l:target[1],1)
					if (l:target[1] != -1)
						if (l:target[0] =~ '\s')
							let l:target = matchstrpos(l:rightline,'\S',l:target[2],1)
							if (l:target[1] != -1)
								let l:rightline = strpart(l:rightline, l:target[1])
								let l:cmdpos = l:cmdpos + l:target[1]
								let l:count -= 1
							else
								let l:cmdpos = ""
								break
							endif
						else
							let l:rightline = strpart(l:rightline, l:target[1])
							let l:cmdpos = l:cmdpos + l:target[1]
							let l:count -= 1
						endif
					else
						let l:cmdpos = ""
						break
					endif
				else
					let l:diff = l:target[2] - l:target[1]
					if (l:diff > 1)
						" € have to treat specially (and all other signs that uses multiple places)
						if (l:target[0] == '€')
							let l:rightline = strpart(l:rightline, l:target[1])
							let l:cmdpos = l:cmdpos + l:target[1]
							let l:count -= 1
						else
							let l:rightline = strpart(l:rightline, l:target[1])
							let l:cmdpos = l:cmdpos + l:target[1]-1
							let l:count -= 1
						endif
					else
						let l:rightline = strpart(l:rightline, l:target[1])
						let l:cmdpos = l:cmdpos + l:target[2]-1
						let l:count -= 1
					endif
				endif
			else
				let l:cmdpos = ""
				break
			endif
		endwhile
	elseif (a:kind[0] ==# 'W')
		while l:count > 0
			let l:target = matchstrpos(l:rightline,'\s',0,1)
			if (l:target[1] != -1)
				let l:target = matchstrpos(l:rightline,'\S',l:target[2],1)
				if (l:target[1] != -1)
					let l:rightline = strpart(l:rightline, l:target[1])
					let l:cmdpos = l:cmdpos + l:target[1]
					let l:count -= 1
				else
					let l:cmdpos = ""
					break
				endif
			else
				let l:cmdpos = ""
				break
			endif
		endwhile
	elseif (a:kind ==# 'iw')
		" 1: "b" move without counts
		let l:target = matchstrpos(l:leftline,'\S\s*$',0,1)
		if (l:target[1] != -1)
			if (l:target[0] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]')
				let l:leftline = strpart(l:leftline, 0, l:target[1]+2)
				let l:lastsign = l:leftline[-2:]
			else
				let l:leftline = strpart(l:leftline, 0, l:target[1]+1)
				let l:lastsign = l:leftline[-1:]
			endif
			if l:lastsign =~ '[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]'
				let l:target = matchstrpos(l:leftline,'[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\+$',0,1)
				let g:oldcmdpos = l:target[1]+1
			else
				let l:target = matchstrpos(l:leftline,'[^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\+$',0,1)
				if l:target[0] =~ '\s'
					let l:position = match(l:target[0],'\S*$',0,1)
					let g:oldcmdpos = l:target[1]+1+l:position
				else
					let g:oldcmdpos = l:target[1]+1
				endif
			endif
		else
			let g:oldcmdpos = 1
		endif
		" 2: "e" move with counts (modified: \s counts here too)
		let l:rightline = strpart(l:cmdline, g:oldcmdpos-1)
		let l:cmdpos = g:oldcmdpos
		while l:count > 0
			if l:rightline[0] =~ '\s'
				let l:target = matchstrpos(l:rightline,'\S',0,1)
				if (l:target[1] != -1)
					let l:rightline = strpart(l:rightline, l:target[1])
					let l:cmdpos = l:cmdpos + l:target[1]
					let l:count -= 1
				else
					let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
					break
				endif
			else
				if ((l:rightline[0] =~ '[A-Za-z0-9_]') || (l:rightline[:1] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]'))
					let l:target = matchstrpos(l:rightline,'[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df][^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]',0,1)
					if (l:target[1] != -1)
						if (l:target[0] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]')
							let l:rightline = strpart(l:rightline, l:target[1]+2)
							let l:cmdpos = l:cmdpos + l:target[1]+2
						else
							let l:rightline = strpart(l:rightline, l:target[1]+1)
							let l:cmdpos = l:cmdpos + l:target[1]+1
						endif
						let l:count -= 1
					else
						let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
						break
					endif
				else
					let l:target = matchstrpos(l:rightline,'[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\|\s',0,1)
					if (l:target[1] != -1)
						let l:rightline = strpart(l:rightline, l:target[1])
						let l:cmdpos = l:cmdpos + l:target[1]
						let l:count -= 1
					else
						let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
						break
					endif
				endif
			endif
		endwhile
	elseif (a:kind ==# 'iW')
		" 1: "B" move without counts
		let l:target = matchstrpos(l:leftline,'\s\S\+\s*$',0,1)
		if (l:target[1] != -1)
			let g:oldcmdpos = l:target[1]+2
		else
			let g:oldcmdpos = 1
		endif
		" 2: "E" move with counts (modified: \s counts here too)
		while l:count > 0
			if l:rightline[0] =~ '\s'
				let l:target = matchstrpos(l:rightline,'\S',0,1)
				if (l:target[1] != -1)
					let l:rightline = strpart(l:rightline, l:target[1])
					let l:cmdpos = l:cmdpos + l:target[1]
					let l:count -= 1
				else
					let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
					break
				endif
			else
				let l:target = matchstrpos(l:rightline,'\s',0,1)
				if (l:target[1] != -1)
					let l:rightline = strpart(l:rightline, l:target[1])
					let l:cmdpos = l:cmdpos + l:target[1]
					let l:count -= 1
				else
					let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
					break
				endif
			endif
		endwhile
	elseif (a:kind ==# 'aw')
		" 1: "b" move without counts
		let l:target = matchstrpos(l:leftline,'\S\s*$',0,1)
		if (l:target[1] != -1)
			if (l:target[0] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]')
				let l:leftline = strpart(l:leftline, 0, l:target[1]+2)
				let l:lastsign = l:leftline[-2:]
			else
				let l:leftline = strpart(l:leftline, 0, l:target[1]+1)
				let l:lastsign = l:leftline[-1:]
			endif
			if l:lastsign =~ '[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]'
				let l:target = matchstrpos(l:leftline,'[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\+$',0,1)
				let g:oldcmdpos = l:target[1]+1
			else
				let l:target = matchstrpos(l:leftline,'[^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\+$',0,1)
				if l:target[0] =~ '\s'
					let l:position = match(l:target[0],'\S*$',0,1)
					let g:oldcmdpos = l:target[1]+1+l:position
				else
					let g:oldcmdpos = l:target[1]+1
				endif
			endif
		else
			let g:oldcmdpos = 1
		endif
		" 2: "w" move with counts (modified: includes the preceding \s if no following exists)
		let l:rightline = strpart(l:cmdline, g:oldcmdpos-1)
		let l:cmdpos = g:oldcmdpos
		while l:count > 0
			let l:target = matchstrpos(l:rightline,'[^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]',0,1)
			if (l:target[1] != -1)
				if (l:target[0] =~ '\s')
					let l:target = matchstrpos(l:rightline,'\S',l:target[2],1)
					if (l:target[1] != -1)
						let l:rightline = strpart(l:rightline, l:target[1])
						let l:cmdpos = l:cmdpos + l:target[1]
						let l:count -= 1
					else
						let l:cmdpos = l:lenght + 1
						break
					endif
				elseif (l:target[1] == 0)
					let l:target = matchstrpos(l:rightline,'\<\|\s',l:target[1],1)
					if (l:target[1] != -1)
						if (l:target[0] =~ '\s')
							let l:target = matchstrpos(l:rightline,'\S',l:target[2],1)
							if (l:target[1] != -1)
								let l:rightline = strpart(l:rightline, l:target[1])
								let l:cmdpos = l:cmdpos + l:target[1]
								let l:count -= 1
							else
								let l:cmdpos = l:lenght + 1
								break
							endif
						else
							let l:rightline = strpart(l:rightline, l:target[1])
							let l:cmdpos = l:cmdpos + l:target[1]
							let l:count -= 1
						endif
					else
						let l:cmdpos = l:lenght + 1
						break
					endif
				else
					let l:diff = l:target[2] - l:target[1]
					if (l:diff > 1)
						" € have to treat specially (and all other signs that uses multiple places)
						if (l:target[0] == '€')
							let l:rightline = strpart(l:rightline, l:target[1])
							let l:cmdpos = l:cmdpos + l:target[1]
							let l:count -= 1
						else
							let l:rightline = strpart(l:rightline, l:target[1])
							let l:cmdpos = l:cmdpos + l:target[1]-1
							let l:count -= 1
						endif
					else
						let l:rightline = strpart(l:rightline, l:target[1])
						let l:cmdpos = l:cmdpos + l:target[2]-1
						let l:count -= 1
					endif
				endif
			else
				let l:cmdpos = l:lenght + 1
				break
			endif
		endwhile
		if (((l:cmdline[l:cmdpos-2] !~ '\s') && (l:cmdline[g:oldcmdpos-2] =~ '\s')) || ((l:cmdpos == (l:lenght + 1)) && (l:cmdline[g:oldcmdpos-2] =~ '\s')))
			let l:leftline = strpart(l:leftline, 0, g:oldcmdpos-1)
			let l:target = matchstrpos(l:leftline,'\S\s*$',0,1)
			if (l:target[1] != -1)
				let g:oldcmdpos = l:target[1]+2
			else
				let g:oldcmdpos = 0
			endif
		endif
	elseif (a:kind ==# 'aW')
		" 1: "B" move without counts
		let l:target = matchstrpos(l:leftline,'\s\S\+\s*$',0,1)
		if (l:target[1] != -1)
			let g:oldcmdpos = l:target[1]+2
		else
			let g:oldcmdpos = 1
		endif
		" 2: "W" move with counts
		while l:count > 0
			let l:target = matchstrpos(l:rightline,'\s',0,1)
			if (l:target[1] != -1)
				let l:target = matchstrpos(l:rightline,'\S',l:target[2],1)
				if (l:target[1] != -1)
					let l:rightline = strpart(l:rightline, l:target[1])
					let l:cmdpos = l:cmdpos + l:target[1]
					let l:count -= 1
				else
					let l:cmdpos = l:lenght + 1
					break
				endif
			else
				let l:cmdpos = l:lenght + 1
				break
			endif
		endwhile
		if ((l:cmdpos == (l:lenght + 1)) && (l:cmdline[g:oldcmdpos-2] =~ '\s'))
			let l:leftline = strpart(l:leftline, 0, g:oldcmdpos-1)
			let l:target = matchstrpos(l:leftline,'\S\s*$',0,1)
			if (l:target[1] != -1)
				let g:oldcmdpos = l:target[1]+2
			else
				let g:oldcmdpos = 0
			endif
		endif
	elseif (a:kind[0] ==# 'e')
		while l:count > 0
			let l:target = matchstrpos(l:rightline,'\S',0,1)
			if (l:target[1] != -1)
				let l:rightline = strpart(l:rightline, l:target[1])
				let l:cmdpos = l:cmdpos + l:target[1]
				if l:target[0] =~ '^[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]'
					let l:target = matchstrpos(l:rightline,'[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df][^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]',0,1)
					if (l:target[1] != -1)
						if (l:target[0] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]')
							let l:rightline = strpart(l:rightline, l:target[1]+2)
							let l:cmdpos = l:cmdpos + l:target[1]+2
						else
							let l:rightline = strpart(l:rightline, l:target[1]+1)
							let l:cmdpos = l:cmdpos + l:target[1]+1
						endif
						let l:count -= 1
					else
						let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
						break
					endif
				elseif l:target[0] =~ '^[^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]'
					let l:target = matchstrpos(l:rightline,'[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\|\s',0,1)
					if (l:target[1] != -1)
						let l:rightline = strpart(l:rightline, l:target[1])
						let l:cmdpos = l:cmdpos + l:target[1]
						let l:count -= 1
					else
						let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
						break
					endif
				endif
			else
				let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
				break
			endif
		endwhile
	elseif (a:kind[0] ==# 'E')
		while l:count > 0
			let l:target = matchstrpos(l:rightline,'\S',0,1)
			if (l:target[1] != -1)
				let l:target = matchstrpos(l:rightline,'\s',l:target[2],1)
				if (l:target[1] != -1)
					let l:rightline = strpart(l:rightline, l:target[1])
					let l:cmdpos = l:cmdpos + l:target[1]
					let l:count -= 1
				else
					let l:cmdpos = matchstrpos(l:cmdline,'\S$',0,1)[2]+1
					break
				endif
			else
				let l:cmdpos = ""
				break
			endif
		endwhile
	elseif (a:kind[0] ==# 'b')
		while l:count > 0
			let l:target = matchstrpos(l:leftline,'\S\s*$',0,1)
			if (l:target[1] != -1)
				" handle german umlaute too
				if (l:target[0] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]')
					let l:leftline = strpart(l:leftline, 0, l:target[1]+2)
					let l:lastsign = l:leftline[-2:]
				else
					let l:leftline = strpart(l:leftline, 0, l:target[1]+1)
					let l:lastsign = l:leftline[-1:]
				endif
				if l:lastsign =~ '[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]'
					let l:target = matchstrpos(l:leftline,'[A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\+$',0,1)
					let l:leftline = strpart(l:leftline, 0, l:target[1])
					let l:cmdpos = l:target[1]+1
					let l:count -= 1
				else
					let l:target = matchstrpos(l:leftline,'[^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\+$',0,1)
					if l:target[0] =~ '\s'
						let l:position = match(l:target[0],'\S*$',0,1)
						let l:leftline = strpart(l:leftline, 0, l:target[1]+l:position)
						let l:cmdpos = l:target[1]+1+l:position
						let l:count -= 1
					else
						let l:leftline = strpart(l:leftline, 0, l:target[1])
						let l:cmdpos = l:target[1]+1
						let l:count -= 1
					endif
				endif
			else
				let l:cmdpos = 1
				break
			endif
		endwhile
	elseif (a:kind[0] ==# 'B')
		while l:count > 0
			let l:target = matchstrpos(l:leftline,'\s\S\+\s*$',0,1)
			if (l:target[1] != -1)
				let l:leftline = strpart(l:leftline, 0, l:target[1]+1)
				let l:cmdpos = l:target[1]+2
				let l:count -= 1
			else
				let l:cmdpos = 1
				break
			endif
		endwhile
	elseif (a:kind ==# 'ge')
		while l:count > 0
			if l:leftline[-1:] =~ '\s'
				let l:target = matchstrpos(l:leftline,'\S\s\+$',0,1)
				let l:leftline = strpart(l:leftline, 0, l:target[1]+1)
				let l:cmdpos = l:target[1]+1
			elseif ((l:leftline[-1:] =~ '[A-Za-z0-9_]') || (l:leftline[-2:] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]'))
				let l:target = matchstrpos(l:leftline,'[^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df][A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\+$',0,1)
				let l:leftline = strpart(l:leftline, 0, l:target[1]+1)
				if l:leftline[-1:] =~ '\s'
					let l:target = matchstrpos(l:leftline,'\S\s\+$',0,1)
					let l:leftline = strpart(l:leftline, 0, l:target[1]+1)
				endif
				let l:cmdpos = l:target[1]+1
			else
				let l:target = matchstrpos(l:leftline,'[^A-Za-z0-9_\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]\+$',0,1)
				if l:target[0] =~ '\s'
					let l:position = match(l:target[0],'\S\s\+\S*$',0,1)
					let l:leftline = strpart(l:leftline, 0, l:target[1]+l:position)
					let l:cmdpos = l:target[1]+1+l:position
				else
					let l:leftline = strpart(l:leftline, 0, l:target[1])
					let l:cmdpos = l:target[1]+1
				endif
			endif
			if (l:target[1] != -1)
				let l:count -= 1
			else
				let l:cmdpos = ""
				break
			endif
		endwhile
	elseif (a:kind ==# 'gE')
		while l:count > 0
			if l:leftline[-1:] =~ '\s'
				let l:target = matchstrpos(l:leftline,'\S\s\+$',0,1)
			else
				let l:target = matchstrpos(l:leftline,'\S\s\+\S\+$',0,1)
			endif
			if (l:target[1] != -1)
				let l:leftline = strpart(l:leftline, 0, l:target[1]+1)
				let l:cmdpos = l:target[1]+1
				let l:count -= 1
			else
				let l:cmdpos = ""
				break
			endif
		endwhile
	elseif (a:kind[0] ==# 'l')
		while l:count > 0
			if (l:cmdpos > l:lenght)
				let l:cmdpos = ""
				break
			else
				let l:cmdpos += 1
				let l:count -= 1
				if (l:cmdline[(l:cmdpos-2):(l:cmdpos-1)] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]')
					let l:cmdpos += 1
				elseif (l:cmdline[(l:cmdpos-2):(l:cmdpos)] =~ '[\u20AC]')
					let l:cmdpos += 2
				endif
			endif
		endwhile
	elseif (a:kind[0] ==# 'h')
		while l:count > 0
			if (l:cmdpos == 0)
				let l:cmdpos = ""
				break
			else
				let l:cmdpos -= 1
				let l:count -= 1
				let g:cmdline = l:cmdline[(l:cmdpos-3):(l:cmdpos-1)]
				if (l:cmdline[(l:cmdpos-2):(l:cmdpos-1)] =~ '[\u00c4\u00e4\u00d6\u00f6\u00dc\u00fc\u00df]')
					let l:cmdpos -= 1
				elseif (l:cmdline[(l:cmdpos-3):(l:cmdpos-1)] =~ '[\u20AC]')
					let l:cmdpos -= 2
				endif
			endif
		endwhile
	elseif (a:kind[0] ==# '$')
		let l:cmdpos = l:lenght + 1
	elseif (a:kind[0] ==# '0')
		let l:cmdpos = 1
	elseif (a:kind[0] ==# '^')
		let l:cmdpos = matchstrpos(l:cmdline,'\S',0,1)[1]+1
	endif
	if (a:return == 1)
		if (l:cmdpos != "")
			call setcmdpos(l:cmdpos)
		endif
		return l:cmdline
	else
		let g:newpos = l:cmdpos
	endif
endfunction
"fFtT movements (also include ;, movements and count highlighting)
function! cmdlineplus#jumpto_char(kind,target,count) "{{{
	let l:cmdline = getcmdline()
	let save_gcr = &gcr
	set gcr=a:block-Cursor-blinkon0
	let &gcr = save_gcr
	if a:target=="\<Esc>"
		return l:cmdline
	end
	let l:rightline = s:_get_rightline(l:cmdline)
	let l:leftline = s:_get_leftline(l:cmdline)
	let l:count = a:count - 1
	let l:highlight = "Question"
	let l:hint = -l:count
	let l:targetpos = -1
	if a:kind=~#'\l'
		let l:prevpos = 0
		let l:echo_string = 'echon ":" ' . string(l:leftline)
		let l:nextpos = stridx(l:rightline, a:target)
		while (l:nextpos != -1)
			if (l:count == 0)
				let l:targetpos = getcmdpos() + l:nextpos + (a:kind==#'f' ? 1 : 0)
				let l:highlight = "Directory"
			elseif (l:count < -9)
				let l:highlight = "Question"
			endif
			if (l:prevpos == l:nextpos)
				let l:echo_appendix = ' | echohl ' . l:highlight . ' | echon ' . string(l:hint) . ' | echohl None'
			else
				let l:echo_appendix = ' | echon ' . string(l:rightline[(l:prevpos):(l:nextpos-1)]) . ' | echohl ' . l:highlight . ' | echon ' . string(l:hint) .' | echohl None'
			endif
			let l:echo_string = l:echo_string . l:echo_appendix
			let l:prevpos = l:nextpos+1
			let l:nextpos = stridx(l:rightline, a:target, l:prevpos)
			let l:hint += 1
			let l:count -= 1
		endwhile
		if (l:prevpos != 0)
			let l:echo_string = l:echo_string . ' | echon ' . string(l:rightline[(l:prevpos):])
		endif
		:redraw
		exe l:echo_string
		:redraw
		call CustomFunSleep(150)
	else
		let l:prevpos = len(l:leftline)
		let l:echo_string = ""
		let l:nextpos = strridx(l:leftline, a:target)
		while (l:nextpos != -1)
			if (l:count == 0)
				let l:targetpos = l:nextpos + (a:kind==#'F' ? 1 : 2)
				let l:highlight = "Directory"
			elseif (l:count < -9)
				let l:highlight = "Question"
			endif
			if ((l:prevpos) == l:nextpos)
				let l:echo_appendix = ' | echohl ' . l:highlight . ' | echon ' . string(l:hint) . ' | echohl None'
			else
				let l:echo_appendix = ' | echohl ' . l:highlight . ' | echon ' . string(l:hint) .' | echohl None | echon ' . string(l:leftline[(l:nextpos+1):(l:prevpos)])
			endif
			let l:echo_string = l:echo_appendix . l:echo_string
			let l:prevpos = l:nextpos-1
			let l:nextpos = strridx(l:leftline, a:target, l:prevpos)
			let l:hint += 1
			let l:count -= 1
		endwhile
		if (l:prevpos != len(l:leftline))
			let l:echo_string = 'echon ":" ' . string(l:leftline[:(l:prevpos)]) . l:echo_string . ' | echon ' . string(l:rightline)
		endif
		:redraw
		exe l:echo_string
		:redraw
		call CustomFunSleep(150)
	endif
	if l:targetpos==-1
		let g:newpos = -1
	else
		let g:newpos = l:targetpos
	end
endfunction

" <c-o> structure
function! cmdlineplus#CTRL_O() "{{{
  let l:cmdline = getcmdline()
	let g:oldcmdpos = getcmdpos()
	let l:startcmdpos = g:oldcmdpos
	let l:operation = 0
	let g:var2 = ""
	let g:var3 = ""
	let l:num2 = 1
	" while loop is used to enable the use of continue during the operator use
	while 1
		let g:var1 = nr2char(getchar())
		if (g:var1 =~ '\d')
			if (g:var1 != '0')
				let g:num0 = g:var1
				let g:var1 = nr2char(getchar())
				if (g:var1 =~ '\d')
					let g:num0 = g:num0 . g:var1
					let g:var1 = nr2char(getchar())
					if (g:var1 =~# "[cC]")
						let l:operation = 1
						if ( g:var1 ==# "C" )
							let g:var1 = "$"
							let g:var2 = "d"
						elseif ( g:var2 == "" )
							let l:num2 = g:num0
							let g:var2 = "d"
							continue
						else
							let g:var1 = "d"
						endif
					elseif (g:var1 =~# "[dy]")
						let l:operation = 1
						if ( g:var2 == "" )
							let l:num2 = g:num0
							let g:var2 = g:var1
							continue
						endif
					elseif (g:var1 == 'g')
						if g:var1 ==# 'G'
							let g:num0 = ""
						else
							let g:var1 = g:var1 . nr2char(getchar())
							if g:var1 =~# 'g[uUs]'
								let l:num2 = g:num0
								let g:var2 = g:var1
								let l:operation = 1
								continue
							endif
						endif
					elseif (g:var1 =~ '[ia]')
						let g:var1 = g:var1 . nr2char(getchar())
					elseif (g:var1 =~ '[fFtT]')
						let g:var1 = g:var1 . nr2char(getchar())
						if g:var1[1] == ''
							let l:qvar1 =  nr2char(getchar())
							let l:qvar2 =  nr2char(getchar())
							if (l:qvar1 ==# 'a')
								let g:var1 = g:var1[0] . "ä"
							elseif (l:qvar1 ==# 'A')
								let g:var1 = g:var1[0] . "Ä"
							elseif (l:qvar1 ==# 'o')
								let g:var1 = g:var1[0] . "ö"
							elseif (l:qvar1 ==# 'O')
								let g:var1 = g:var1[0] . "Ö"
							elseif (l:qvar1 ==# 'u')
								let g:var1 = g:var1[0] . "ü"
							elseif (l:qvar1 ==# 'U')
								let g:var1 = g:var1[0] . "Ü"
							elseif (l:qvar1 ==# 'E')
								let g:var1 = g:var1[0] . "€"
							elseif (l:qvar1 ==# 's')
								let g:var1 = g:var1[0] . "ß"
							else
								let g:var1 = g:var1 . l:qvar1 . l:qvar2
							endif
						endif
						let g:fFtT_move = g:var1
						let g:fFtT_number = g:num0
					elseif (g:var1 == ';')
						let g:var1 = g:fFtT_move
						let g:fFtT_number = g:num0
					elseif (g:var1 == ',')
						let g:fFtT_number = g:num0
						if (g:fFtT_move[0] =~# "[ft]")
							let g:var1 = toupper(g:fFtT_move[0]) . g:fFtT_move[1:]
						else
							let g:var1 = tolower(g:fFtT_move[0]) . g:fFtT_move[1:]
						endif
					elseif (g:var1 == '.')
						let g:var1 = g:dot_var1
						let g:var2 = g:dot_var2
						let l:operation = 1
					endif
				elseif (g:var1 =~# "[cC]")
					let l:operation = 1
					if ( g:var1 ==# "C" )
						let g:var1 = "$"
						let g:var2 = "d"
					elseif ( g:var2 == "" )
						let l:num2 = g:num0
						let g:var2 = "d"
						continue
					else
						let g:var1 = "d"
					endif
				elseif (g:var1 =~# "[dy]")
					let l:operation = 1
					if ( g:var2 == "" )
						let l:num2 = g:num0
						let g:var2 = g:var1
						continue
					endif
				elseif (g:var1 == 'g')
					if g:var1 ==# 'G'
						let g:num0 = ""
					else
						let g:var1 = g:var1 . nr2char(getchar())
						if g:var1 =~# 'g[uUs]'
							let l:num2 = g:num0
							let g:var2 = g:var1
							let l:operation = 1
							continue
						endif
					endif
				elseif (g:var1 =~ '[ia]')
					let g:var1 = g:var1 . nr2char(getchar())
				elseif (g:var1 =~ '[fFtT]')
					let g:var1 = g:var1 . nr2char(getchar())
					if g:var1[1] == ''
						let l:qvar1 =  nr2char(getchar())
						let l:qvar2 =  nr2char(getchar())
						if (l:qvar1 ==# 'a')
							let g:var1 = g:var1[0] . "ä"
						elseif (l:qvar1 ==# 'A')
							let g:var1 = g:var1[0] . "Ä"
						elseif (l:qvar1 ==# 'o')
							let g:var1 = g:var1[0] . "ö"
						elseif (l:qvar1 ==# 'O')
							let g:var1 = g:var1[0] . "Ö"
						elseif (l:qvar1 ==# 'u')
							let g:var1 = g:var1[0] . "ü"
						elseif (l:qvar1 ==# 'U')
							let g:var1 = g:var1[0] . "Ü"
						elseif (l:qvar1 ==# 'E')
							let g:var1 = g:var1[0] . "€"
						elseif (l:qvar1 ==# 's')
							let g:var1 = g:var1[0] . "ß"
						else
							let g:var1 = g:var1 . l:qvar1 . l:qvar2
						endif
					endif
					let g:fFtT_move = g:var1
					let g:fFtT_number = g:num0
				elseif (g:var1 == ';')
					let g:var1 = g:fFtT_move
					let g:fFtT_number = g:num0
				elseif (g:var1 == ',')
					let g:fFtT_number = g:num0
					if (g:fFtT_move[0] =~# "[ft]")
						let g:var1 = toupper(g:fFtT_move[0]) . g:fFtT_move[1:]
					else
						let g:var1 = tolower(g:fFtT_move[0]) . g:fFtT_move[1:]
					endif
				elseif (g:var1 == '.')
					let g:var1 = g:dot_var1
					let g:var2 = g:dot_var2
					let l:operation = 1
				endif
			else
				let g:num0 = ""
			endif
		else
			let g:num0 = 1
			if (g:var1 =~# "[cC]")
				let l:operation = 1
				if ( g:var1 ==# "C" )
					let g:var1 = "$"
					let g:var2 = "d"
				elseif ( g:var2 == "" )
					let g:var2 = "d"
					continue
				else
					let g:var1 = "d"
				endif
			elseif (g:var1 =~# "[dy]")
				let l:operation = 1
				if ( g:var2 == "" )
					let g:var2 = g:var1
					continue
				endif
			elseif (g:var1 == 'g')
				if g:var1 ==# 'G'
					let g:num0 = ""
				else
					let g:var1 = g:var1 . nr2char(getchar())
					if g:var1 =~# 'g[uUs]'
						let g:var2 = g:var1
						let l:operation = 1
						continue
					endif
				endif
			elseif (g:var1 =~ '[ia]')
				let g:var1 = g:var1 . nr2char(getchar())
			elseif (g:var1 =~ '[fFtT]')
				let g:var1 = g:var1 . nr2char(getchar())
				if g:var1[1] == ''
					let l:qvar1 =  nr2char(getchar())
					let l:qvar2 =  nr2char(getchar())
					if (l:qvar1 ==# 'a')
						let g:var1 = g:var1[0] . "ä"
					elseif (l:qvar1 ==# 'A')
						let g:var1 = g:var1[0] . "Ä"
					elseif (l:qvar1 ==# 'o')
						let g:var1 = g:var1[0] . "ö"
					elseif (l:qvar1 ==# 'O')
						let g:var1 = g:var1[0] . "Ö"
					elseif (l:qvar1 ==# 'u')
						let g:var1 = g:var1[0] . "ü"
					elseif (l:qvar1 ==# 'U')
						let g:var1 = g:var1[0] . "Ü"
					elseif (l:qvar1 ==# 'E')
						let g:var1 = g:var1[0] . "€"
					elseif (l:qvar1 ==# 's')
						let g:var1 = g:var1[0] . "ß"
					else
						let g:var1 = g:var1 . l:qvar1 . l:qvar2
					endif
				endif
				let g:fFtT_move = g:var1
				let g:fFtT_number = g:num0
			elseif (g:var1 == ';')
				let g:var1 = g:fFtT_move
				let g:num0 = g:fFtT_number
			elseif (g:var1 == ',')
				let g:num0 = g:fFtT_number
				if (g:fFtT_move[0] =~# "[ft]")
					let g:var1 = toupper(g:fFtT_move[0]) . g:fFtT_move[1:]
				else
					let g:var1 = tolower(g:fFtT_move[0]) . g:fFtT_move[1:]
				endif
			elseif (g:var1 == '.')
				let l:operation = 1
				let g:num0 = g:dot_num
				let g:var1 = g:dot_var1
				let g:var2 = g:dot_var2
			elseif (g:var1 == '"')
				let g:var3 = nr2char(getchar())
				continue
			elseif (g:var1 == 'q')
				let g:var1 = g:var1 . nr2char(getchar())
			endif
		endif
		break
	endwhile
	" command execution part
	if (((g:var1 ==# 'u') && (g:var2 == '')) || (g:var1 == ''))
		if ((len(g:undo_hist_cmdline_con)) == (g:undo_hist_cmdline_pos))
			call add(g:undo_hist_cmdline_con, l:cmdline)
			call add(g:undo_hist_cmdline_cur, g:oldcmdpos)
		endif
		if (g:var1 ==# 'u')
			if ((g:undo_hist_cmdline_pos-g:num0) >= 0)
				let g:undo_hist_cmdline_pos -= g:num0
			else
				let g:undo_hist_cmdline_pos = 0
			endif
			call setcmdpos(g:undo_hist_cmdline_cur[g:undo_hist_cmdline_pos])
		else
			if ((g:undo_hist_cmdline_pos+g:num0) < (len(g:undo_hist_cmdline_con)))
				let g:undo_hist_cmdline_pos += g:num0
			else
				let g:undo_hist_cmdline_pos = len(g:undo_hist_cmdline_con)-1
			endif
			call setcmdpos(g:undo_hist_cmdline_cur[g:undo_hist_cmdline_pos-1])
		endif
		let l:cmdline = g:undo_hist_cmdline_con[g:undo_hist_cmdline_pos]
	elseif (g:var1[0] ==# 'q')
		call feedkeys("")
	elseif (g:var1 ==# 'p')
		" save operation and movement for dot cmd
		let g:dot_num  = g:num0
		let g:dot_var1 = g:var1
		let g:dot_var2 = g:var2
		if (g:var3 == '')
			let l:pastitem = getreg(0)
		else
			let l:pastitem = getreg(g:var3)
		endif
		let l:pastNitem = l:pastitem
		let l:count = g:num0 - 1
		while l:count > 0
			let l:pastNitem = l:pastNitem . l:pastitem
			let l:count -= 1
		endwhile
		if g:oldcmdpos != 1
			let l:cmdline = l:cmdline[:(g:oldcmdpos-2)] . l:pastNitem . l:cmdline[(g:oldcmdpos-1):]
		else
			let l:cmdline = l:pastNitem . l:cmdline
		endif
		call setcmdpos(g:oldcmdpos+(len(l:pastNitem)))
	else
		if l:num2 > 1
			let g:num0 = l:num2
		endif
		if (g:var1[0] =~# '[fFtT]')
			call cmdlineplus#jumpto_char(g:var1[0],g:var1[1:],g:num0)
		elseif (g:var1 =~# '[dyDYUus]') " catch and handle dd, cc, yy, D, C, Y, gss, guu, gUU
			if (g:var2 ==# 'd')
				let l:operation = 1
				let g:var2 = "d"
				let g:oldcmdpos = 1
				let g:newpos = strlen(l:cmdline)+1
			elseif (g:var1 ==# 'D')
				let l:operation = 1
				let g:var2 = "d"
				call cmdlineplus#Motions("$",g:num0,0)
			elseif (g:var1 ==# 'y')
				let l:operation = 1
				let g:var2 = "y"
				let g:oldcmdpos = 1
				let g:newpos = strlen(l:cmdline)+1
			elseif (g:var1 ==# 'Y')
				let l:operation = 1
				let g:var2 = "y"
				call cmdlineplus#Motions("$",g:num0,0)
			elseif (g:var1 ==# 'u')
				let l:operation = 1
				let g:var2 = "gu"
				let g:oldcmdpos = 1
				let g:newpos = strlen(l:cmdline)+1
			elseif (g:var1 ==# 'U')
				let l:operation = 1
				let g:var2 = "gU"
				let g:oldcmdpos = 1
				let g:newpos = strlen(l:cmdline)+1
			elseif (g:var1 ==# 's')
				let l:operation = 1
				let g:var2 = "gs"
				let g:oldcmdpos = 1
				let g:newpos = strlen(l:cmdline)+1
			endif
		else
			call cmdlineplus#Motions(g:var1,g:num0,0)
		endif
		if (g:newpos != '')
			if (l:operation == 1)
				if ((len(g:undo_hist_cmdline_con)) != (g:undo_hist_cmdline_pos))
					call filter(g:undo_hist_cmdline_con, 'v:key <= g:undo_hist_cmdline_pos')
					call filter(g:undo_hist_cmdline_cur, 'v:key <= g:undo_hist_cmdline_pos')
					let g:undo_hist_cmdline_pos = len(g:undo_hist_cmdline_con)
				endif
				if ((g:undo_hist_cmdline_con == []) || (l:cmdline !=# (g:undo_hist_cmdline_con[-1])))
					call add(g:undo_hist_cmdline_con, l:cmdline)
					call add(g:undo_hist_cmdline_cur, g:oldcmdpos)
					let g:undo_hist_cmdline_pos += 1
				endif
				" save operation and movement for dot cmd
				let g:dot_num  = g:num0
				let g:dot_var1 = g:var1
				let g:dot_var2 = g:var2
				call setcmdpos(g:oldcmdpos)
				if (g:var2 ==# 'd')
					if g:oldcmdpos == 1
						let l:target = l:cmdline[:(g:newpos-2)]
						let l:cmdline = l:cmdline[(g:newpos-1):]
					elseif g:oldcmdpos < g:newpos
						let l:target = l:cmdline[(g:oldcmdpos-1):(g:newpos-2)]
						let l:cmdline = l:cmdline[:(g:oldcmdpos-2)] . l:cmdline[(g:newpos-1):]
					else
						call setcmdpos(g:newpos)
						let g:undo_hist_cmdline_cur[-1] = g:newpos
						if (g:newpos == 1)
							let l:target = l:cmdline[:(g:oldcmdpos-2)]
							let l:cmdline = l:cmdline[(g:oldcmdpos-1):]
						else
							let l:target = l:cmdline[(g:newpos-1):(g:oldcmdpos-2)]
							let l:cmdline = l:cmdline[:(g:newpos-2)] . l:cmdline[(g:oldcmdpos-1):]
						endif
					endif
					if (g:var3 == '')
						if (g:var1 !~# '[hl]')
							call setreg('"', l:target)
							call setreg('*', l:target)
							call setreg('+', l:target)
							call setreg('-', l:target)
						endif
					else
						call setreg(g:var3, l:target)
					endif
					:YRPush '"'
				elseif (g:var2 ==# 'y')
					:redraw
					if g:oldcmdpos == 1
						let l:target = l:cmdline[:(g:newpos-2)]
						echon ":" | echohl Error | echon l:target | echohl None | echon l:cmdline[(g:newpos-1):]
					elseif g:oldcmdpos < g:newpos
						let l:target = l:cmdline[(g:oldcmdpos-1):(g:newpos-2)]
						echon ":" . l:cmdline[:(g:oldcmdpos-2)] | echohl Error | echon l:target | echohl None | echon l:cmdline[(g:newpos-1):]
					else
						if (g:newpos == 1)
							let l:target = l:cmdline[:(g:oldcmdpos-2)]
							echon ":" | echohl Error | echon l:target | echohl None | echon l:cmdline[(g:oldcmdpos-1):]
						else
							let l:target = l:cmdline[(g:newpos-1):(g:oldcmdpos-2)]
							echon ":" . l:cmdline[:(g:newpos-2)] | echohl Error | echon l:target | echohl None | echon l:cmdline[(g:oldcmdpos-1):]
						endif
					endif
					if (g:var3 == '')
						call setreg('"', l:target)
						call setreg('*', l:target)
						call setreg('+', l:target)
					else
						call setreg(g:var3, l:target)
					endif
					:YRPush '"'
					:redraw
					call CustomFunSleep(150)
					if ((g:var1 ==# 'y') || (g:var1 =~# '[ia][wW]' ))
						call setcmdpos(l:startcmdpos)
					endif
				elseif (g:var2 ==# 'gU')
					if g:oldcmdpos == 1
						let l:cmdline = (toupper(l:cmdline[:(g:newpos-2)])) . l:cmdline[(g:newpos-1):]
					elseif g:oldcmdpos < g:newpos
						let l:cmdline = l:cmdline[:(g:oldcmdpos-2)] . (toupper(l:cmdline[(g:oldcmdpos-1):(g:newpos-2)])) . l:cmdline[(g:newpos-1):]
					else
						call setcmdpos(g:newpos)
						if (g:newpos == 1)
							let l:cmdline = (toupper(l:cmdline[:(g:oldcmdpos-2)])) . l:cmdline[(g:oldcmdpos-1):]
						else
							let l:cmdline = l:cmdline[:(g:newpos-2)] . (toupper(l:cmdline[(g:newpos-1):(g:oldcmdpos-2)])) . l:cmdline[(g:oldcmdpos-1):]
						endif
					endif
				elseif (g:var2 ==# 'gu')
					if g:oldcmdpos == 1
						let l:cmdline = (tolower(l:cmdline[:(g:newpos-2)])) . l:cmdline[(g:newpos-1):]
					elseif g:oldcmdpos < g:newpos
						let l:cmdline = l:cmdline[:(g:oldcmdpos-2)] . (tolower(l:cmdline[(g:oldcmdpos-1):(g:newpos-2)])) . l:cmdline[(g:newpos-1):]
					else
						call setcmdpos(g:newpos)
						if (g:newpos == 1)
							let l:cmdline = (tolower(l:cmdline[:(g:oldcmdpos-2)])) . l:cmdline[(g:oldcmdpos-1):]
						else
							let l:cmdline = l:cmdline[:(g:newpos-2)] . (tolower(l:cmdline[(g:newpos-1):(g:oldcmdpos-2)])) . l:cmdline[(g:oldcmdpos-1):]
						endif
					endif
				elseif (g:var2 ==# 'gs')
					if (g:var3 == '')
						let l:pastitem = getreg(0)
					else
						let l:pastitem = getreg(g:var3)
					endif
					if g:oldcmdpos == 1
						if (g:var1 ==# 's')
							call setcmdpos(1)
						else
							call setcmdpos(g:oldcmdpos+(len(l:pastitem)))
						endif
						let l:cmdline =  l:pastitem . l:cmdline[(g:newpos-1):]
					elseif g:oldcmdpos < g:newpos
						call setcmdpos(g:oldcmdpos+(len(l:pastitem)))
						let l:cmdline = l:cmdline[:(g:oldcmdpos-2)] . l:pastitem . l:cmdline[(g:newpos-1):]
					else
						call setcmdpos(g:newpos+(len(l:pastitem)))
						if (g:newpos == 1)
							let l:cmdline = l:pastitem . l:cmdline[(g:oldcmdpos-1):]
						else
							let l:cmdline = l:cmdline[:(g:newpos-2)] . l:pastitem . l:cmdline[(g:oldcmdpos-1):]
						endif
					endif
				endif
			else
				call setcmdpos(g:newpos)
			endif
		endif
	endif
	return l:cmdline
endfunction

" supporting functions 
function! s:_get_leftline(cmdline) "{{{
  return strpart(a:cmdline, 0, getcmdpos()-1)
endfunction
"}}}
function! s:_get_rightline(cmdline) "{{{
  return strpart(a:cmdline, getcmdpos()-1)
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
