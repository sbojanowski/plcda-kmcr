xquery version "1.0";
(:
	Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools
	see https://art-decor.org/mediawiki/index.php?title=Copyright
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)
import module namespace art   = "http://art-decor.org/ns/art" at "/db/apps/art/modules/art-decor.xqm";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace sm    = "http://exist-db.org/xquery/securitymanager";
import module namespace repo  = "http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;
(:install path for art (/db, /db/apps), no trailing slash :)
declare variable $root := repo:get-root();

let $decorTypes := art:getDecorTypes(true())

return ()