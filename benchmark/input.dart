const input = '''
[b]bolded text[/b]
[i]italicized text[/i]
[u]underlined text[/u]
[s]strikethrough text[/s]
[url]https://en.wikipedia.org[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
[img]https://upload.wikimedia.org/wikipedia/commons/9/90/JustAnExample.JPG[/img]

<p align="center">
  <img alt="BBob a BBCode processor" src="https://github.com/JiLiZART/bbob/blob/master/.github/logo.png?raw=true" />


BBob is a tool to parse and transform [wiki=en]BBCode[/wiki]
written in pure javascript, no dependencies

<a href="https://travis-ci.org/JiLiZART/bbob">
  <img src="https://travis-ci.org/JiLiZART/bbob.svg?branch=master" alt="Build Status">
</a>
<a href="https://codecov.io/gh/JiLiZART/bbob">
  <img src="https://codecov.io/gh/JiLiZART/bbob/branch/master/graph/badge.svg" alt="codecov">
</a>
<a href="https://www.codefactor.io/repository/github/jilizart/bbob">
  <img src="https://www.codefactor.io/repository/github/jilizart/bbob/badge" alt="CodeFactor">
</a>
<a href="https://bettercodehub.com/">
<img src="https://bettercodehub.com/edge/badge/JiLiZART/bbob?branch=master" alt="BCH compliance">
</a>
<a href="https://snyk.io/test/github/JiLiZART/bbob?targetFile=package.json">
  <img src="https://snyk.io/test/github/JiLiZART/bbob/badge.svg?targetFile=package.json" alt="Known Vulnerabilities">
</a>

[big]Packages[/big]

| Package              | Status                                                     | Size    | Description               |
|----------------------|------------------------------------------------------------|---------|---------------------------|
| [user]bbob/core[/user]           | [[img]https://npmjs.com/package/[user]bbob/core[/img[/user]]                 | ![[user]bbob/core-size[/user]] | Core package              |
| [user]bbob/react[/user]          | [[img]https://npmjs.com/package/[user]bbob/react[/img[/user]]               | ![[user]bbob/react-size[/user]]  | React renderer            |
| [user]bbob/preset-react[/user]   | [[img]https://npmjs.com/package/[user]bbob/preset-react[/img[/user]] | ![[user]bbob/preset-react-size[/user]]  | React default tags preset |
| [user]bbob/html[/user]           | [[img]https://npmjs.com/package/[user]bbob/html[/img[/user]]                 | ![[user]bbob/html-size[/user]]  | HTML renderer             |
| [user]bbob/preset-html5[/user]   | [[img]https://npmjs.com/package/[user]bbob/preset-html5[/img[/user]] | ![[user]bbob/preset-html5-size[/user]]  | HTML5 default tags preset |

[url=https://codepen.io/JiLiZART/full/vzMvpd]DEMO Playground[/url]

[big]Table of contents[/big]

[list]
[*] [Usage]([project]usage[/project])
[list][*] [Basic usage]([project]basic-usage[/project])
[*] [React usage]([project]react-usage[/project])[/list]
[*] [Presets]([project]presets[/project])
[list][*] [Create your own preset]([project]create-preset[/project])
[*] [HTML Preset]([project]html-preset[/project])
[*] [React Preset]([project]react-preset[/project])[/list]
[*] [React usage]([project]react[/project])
[list][*] [Component]([project]react-component[/project])
[*] [Render prop]([project]react-render[/project])[/list]
[*] [PostHTML usage]([project]posthtml[/project])
[*] [Create Plugin]([project]plugin[/project])
[/list]
[small]Basic usage <a name="basic-usage"></a>[/small]

[code=shell]
npm i @bbob/core @bbob/html @bbob/preset-html5
[/code][code=js]
import bbobHTML from '@bbob/html'
import presetHTML5 from '@bbob/preset-html5'

const processed = bbobHTML(`[i]Text[/i]`, presetHTML5())

console.log(processed); // <span style="font-style: italic;">Text</span>
[/code]

[small]React usage <a name="react-usage"></a>[/small]

[code=shell]
npm i @bbob/react @bbob/preset-react
[/code][code=js]
import React from 'react'
import {render} from 'react-dom'
import bbobReactRender from '@bbob/react/es/render'
import presetReact from '@bbob/preset-react'

console.log(render(<span>{bbobReactRender(`[i]Text[/i]`, presetReact(), { onlyAllowTags: ['i'] })}</span>)); // <span><span style="font-style: italic;">Text</span></span>
[/code]

[small]Presets <a name="basic"></a>[/small]

Its a way to transform parsed BBCode AST tree to another tree by rules in preset

Create your own preset <a name="create-preset"></a>

[code=js]
import { createPreset } from '@bbob/preset'

export default createPreset({
  quote: (node) => ({
    tag: 'blockquote',
    attrs: node.attrs,
    content: [{
      tag: 'p',
      attrs: {},
      content: node.content,
    }],
  }),
})
[/code]

HTML Preset <a name="html-preset"></a>

Also you can use predefined preset for HTML
[code=js]
import html5Preset from '@bbob/preset-html5/es'
import { render } from '@bbob/html/es'
import bbob from '@bbob/core'

console.log(bbob(html5Preset()).process(`[quote]Text[/quote]`, { render }).html) // <blockquote><p>Text</p></blockquote>
[/code]

React Preset <a name="react-preset"></a>

Also you can use predefined preset for React
[code=js]
import reactPreset from "@bbob/preset-react";
import reactRender from "@bbob/react/es/render";

const preset = reactPreset.extend((tags, options) => ({
  quote: node => ({
    tag: "blockquote",
    content: node.content
  })
}));

const result = reactRender(`[quote]Text[/quote]`, reactPreset());

/*
It produces a VDOM Nodes equal to
React.createElement('blockquote', 'Text')
*/
document.getElementById("root").innerHTML = JSON.stringify(result, 4);
[/code]
[[img]https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/lp7q9yj0lq[/img]

[small]React usage <a name="react"></a>[/small]

Component <a name="react-component"></a>

Or you can use React Component
[code=js]
import React from 'react'
import { render } from 'react-dom'

import BBCode from '@bbob/react/es/Component'
import reactPreset from '@bbob/preset-react/es'

const MyComponent = () => (
  <BBCode plugins={[reactPreset()]} options={{ onlyAllowTags: ['i'] }}>
    [quote]Text[/quote]
  </BBCode>
)

render(<MyComponent />) // <div><blockquote><p>Text</p></blockquote></div>
[/code][[img]https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/306pzr9k5p[/img]

Render prop <a name="react-render"></a>

Or pass result as render prop
[code=js]
import React from "react";
import { render } from 'react-dom'

import reactRender from '@bbob/react/es/render'
import reactPreset from '@bbob/preset-react/es'

const toReact = input => reactRender(input, reactPreset())

const text = toReact('[b]Super [i]easy[/i][/b] [u]to[/u] render')

const App = ({ renderProp }) => (
  <span>{text}</span>
)

render(<App />) // <span><span style="font-weight: bold;">Super <span style="font-style: italic;">easy</span></span> <span style="text-decoration: underline;">to</span> render</span>
[/code]
[[img]https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/x7w52lqmzz[/img]

[small]PostHTML usage <a name="posthtml"></a>[/small]

[small]Create Plugin <a name="plugin"></a>[/small]

[b]bolded text[/b][b]bolded text[/b][b]bolded text[/b][b]bolded text[/b][b]bolded text[/b][b]bolded text[/b][b]bolded text[/b]
[i]italicized text[/i]
[u]underlined text[/u][u]underlined text[/u][u]underlined text[/u][u]underlined text[/u][u]underlined text[/u]
[u]underlined text[/u][u]underlined text[/u][u]underlined text[/u][u]underlined text[/u][u]underlined text[/u]
[s]strikethrough text[/s]
[url]https://en.wikipedia.org[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url][url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url][url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url][url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
[url=https://en.wikipedia.org]English Wikipedia[/url]
''';
