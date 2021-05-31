-- WoW doesn't sort lua tables when writing them, and because of the way lua tables are implemented,
-- the order in which keys are enumerated varies. As a result each time wow serializes the lua
-- tables, their content end up in a different order in the file. This is bad when using a dvcs to
-- track those files because it generates a lot of bogus differences and wastes a lot of space and
-- bandwidth.
--
-- This script solves this by going goes through all the lua files in the WTF directory, loading
-- them, and writing them back with their keys in alphabetical order. It has to be called
-- before each commit to keep the order of things stable and avoid unwanted deltas.
--
-- A reasonable effort has been made to use the same layout and indention rules as wow when
-- rewriting the files, but all the idiosyncrasies of wow's lua serializer haven't been emulated.
-- For instance, when writing the values located in the array part of a lua table (with incrementing
-- index numbers), wow explicitely saves "nil" for the empty slots. This script doesn't. It shouldn't
-- make any difference.


local function orderingFunc( a, b )
	local typeA = type( a )
	local typeB = type( b )

    if typeA == typeB then
        return a < b
	elseif typeA == "number" then
		return true
	else
        return false
    end
end


-- This function generates a sorted index for the provided table by generating an array containing the keys
-- for this table and then sorting it.
function BuildIndex( t )
	local index = {}

	for k, v in pairs( t ) do
		table.insert( index, k )
	end

	-- Some tables have a mix of number and string keys, so we use a function that does a tostring before comparing.
	-- Otherwise we'd get a lua error for comparing values of different types.
	table.sort( index, orderingFunc )
	return index
end

indentlevel = 0

function Indent( outfile )
	local i = indentlevel
	while( i > 0 ) do
		outfile:write '\t'
		i = i - 1
	end
end

-- Write a primitive value. Strings are formatted using string.format's %q but newlines are also
-- replaced with \n to match the way wow formats strings when it writes the lua files.
-- Anything else is just converted using tostring().
function WritePrimitive( outfile, p )
	if( type( p ) == 'string' ) then
		local newstr = string.format( '%q', p )
		newstr = string.gsub( newstr, '\n', 'n' )
		outfile:write( newstr )
	else
		outfile:write( tostring( p ) )
	end
end

-- Write out a value. The value can be a table, in which case it'll recurse through it.
function WriteTableValue( outfile, val )
	if( type( val ) == 'table' ) then
		outfile:write '{\n'
		indentlevel = indentlevel + 1

		-- Integer indices
		for i, v in ipairs( val ) do
			Indent( outfile );
			WriteTableValue( outfile, v );
			outfile:write( ', -- [' .. i .. ']\n' )

			val[i] = nil
		end

		index = BuildIndex( val )

		-- Non-integer keys
		for i, k in ipairs( index ) do
			Indent( outfile );
			outfile:write '['; WritePrimitive( outfile, k ); outfile:write '] = '
			WriteTableValue( outfile, val[k] )
			outfile:write ',\n'
		end

		indentlevel = indentlevel - 1
		Indent( outfile ); outfile:write '}'
	else
		WritePrimitive( outfile, val )
	end
end

function ProcessLuaFile( filename )
	local tables = {}

	-- Load the lua file as a lua function, give it tables as environment
	-- and execute it. This will deserialize all the lua tables from the file in tables.
	luafilefunc = loadfile( filename )

	if( luafilefunc == nil ) then
		return
	end

	setfenv( luafilefunc, tables )
	luafilefunc()

	-- Create a new file to write the sorted tables to, we'll rename it when we're done.
	-- This is to avoid destroying the original file if the script is interrupted half-way for
	-- some reason.
	outfile = io.open( filename..'.sorted', 'w' )

	-- WoW writes a newline first, do the same in case it's a workaround for something or
	-- if other tools manipulating those files expect it to be there.
	outfile:write '\n'

	-- I don't know if integer keys are ever used at the root level of the file, so here's a test
	-- to find out.
	if( #tables ~= 0 ) then
		error( 'Integer keys used at root level of file ' .. filename )
	end

	-- Sort the root table.
	index = BuildIndex( tables )

	-- Write out each table along with its sub-tables, recursively.
	for i, k in pairs( index ) do
		outfile:write( k .. ' = ' )
		WriteTableValue( outfile, tables[k] )
		outfile:write '\n'
	end

	outfile:close()

	-- Delete the old file and rename the new one.
	os.remove( filename );
	os.rename( filename..'.sorted', filename )
end

-- Put all file names ending in .lua in the retail folder into a hidden file called .luafiles
os.execute 'dir /b /s WTF\\*.lua >.luafiles'

-- open the file
luafiles = io.open '.luafiles'

-- sort each lua file
for filename in luafiles:lines() do
	--print(filename)
	ProcessLuaFile( filename );
end

-- close and delete list of .lua files
luafiles:close()
os.execute 'del .luafiles'