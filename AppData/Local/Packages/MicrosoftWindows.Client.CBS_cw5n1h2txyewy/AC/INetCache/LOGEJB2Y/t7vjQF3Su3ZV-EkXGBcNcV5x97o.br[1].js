var WebResultToolboxBlueV2;(function(){function tt(){var n=_ge("b_results"),t=_ge("b_context");(n||t)&&typeof sa_CTBConfig!="undefined"&&sa_CTBConfig&&(r[b]=ot,r[k]=l,r[d]=l,r[g]=c,r[nt]=c,sj_be(sj_b,"click",function(n){u(n)}),sj_evt.bind("onPopTR",function(n){u(n,!0)}),sj_be(sj_b,"mousedown",function(n){h(n)}),sj_be(sj_b,"mouseup",function(n){h(n)}),n&&s(n.firstChild),t&&s(t.firstChild))}function it(n){return _G.abdef_sarc!=undefined&&n.classList.contains(_G.abdef_sarc)}function s(n){n&&n.nodeType==1&&!it(n)&&(ut(n),s(n.nextSibling))}function rt(n,t,i){for(var r=-1;i--&&r++<n.length;)if(r=n.indexOf(t,r),r<0)break;return r}function ut(n){var y,u,t,c,f,s,l,a;if(n){var r=ct(sa_CTBConfig.toolboxTriggerClassName,n,"span"),h=n.getElementsByTagName("cite"),e=v(n,"u");e&&i(e,"u")[0]==="e"&&(e=null);y=sa_CTBConfig&&sa_CTBConfig.disableMetaData=="1";r&&(h.length||y)&&(u=h.length>0?h[0]:null,n.tt=r,ft(n,e)&&bt(n)&&(t=sj_ce("a"),t.href="#",t.className="trgr_icon",t.setAttribute("aria-label",sa_CTBConfig.TRGT),t.setAttribute("aria-haspopup","true"),t.setAttribute("aria-expanded","false"),t.setAttribute("tabindex","0"),t.setAttribute("role","button"),sj_be(t,"click",et),sa_CTBConfig.isMobile&&r.parentNode.classList.add("b_attrtbm"),r.parentNode.replaceChild(t,r),t.appendChild(r),c=sj_ce("span","","c_tlbxTrgIcn "+sa_CTBConfig.staticIconClass),n.ti=c,r.insertBefore(c,r.firstChild),o&&u!=null&&(f=u.textContent,s=rt(f,"/",f.indexOf("http")===0?3:1),f&&s>0&&(l=sj_ce("span",null,"b_url_domain"),l.textContent=f.substring(0,s),a=sj_ce("span",null,"b_url_path"),a.textContent=f.substring(s),u.innerHTML="",u.appendChild(l),u.appendChild(a)))))}}function ft(n,t){var f=sj_ce("div",null,"c_tlbx"),e,h,o,s,u;for(h in n.tt.childNodes)o=n.tt.childNodes[h],s=i(o,"h"),s&&(u=sj_ce("div"),r[s](n,t,o,u),u.childNodes.length&&(e&&(e.className+=" c_tlbxIS"),f.appendChild(u),e=u));return f.childNodes.length?(n.toolbox=f,!0):!1}function et(t){var i=lt(sj_et(t)),o,r,f,e;return i?(o=n,u(t),r=i.toolbox,r&&r!=o&&(i.ti.className=i.ti.className.replace(sa_CTBConfig.staticIconClass,sa_CTBConfig.selectedIconClass),i.tt.className+=" sel",f=sa_CTBConfig.useOffsetParent=="1"?i.ti.offsetParent:null,sa_CTBConfig.isMobile?yt(i,r,f):(r.style.top=sj_go(i.ti,"Top",f)+y()+"px",r.style.left=sj_go(i.ti,"Left",f)+p()+"px"),i.toolboxPlaceholder.appendChild(r),i.tt.parentNode.setAttribute("aria-expanded","true"),n=r,n.caption=i,vt(i)),e=t&&t.srcElement&&t.srcElement.parentNode,e&&e.setAttribute("aria-expanded","true"),st(t)):!0}function u(t,i){var u,r,f;return i===void 0&&(i=!1),n&&(u=sj_et(t),r=n.caption,(i||!sj_we(u,n,r))&&(r.ti.className=r.ti.className.replace(sa_CTBConfig.selectedIconClass,sa_CTBConfig.staticIconClass),r.tt.className=r.tt.className.replace(/ sel/g,""),n.parentNode.removeChild(n),n=0),f=r.tt.parentNode,f&&f.setAttribute("aria-expanded","false"),sj_we(u,r)&&sj_sp(t)),!0}function h(t){if(n){var i=sj_et(t),r=n.caption;i.tagName.toLowerCase()!="a"&&sj_we(i,r)&&sj_sp(t)}return!0}function ot(n,t,r,u){var f;if(!sa_CTBConfig.disableCached&&sa_CTBConfig.CU&&(f=i(t,"u"),f)){var o=sa_CTBConfig.NW=="1"?!0:undefined,e=f.split("|"),s=sa_CTBConfig.CU.replace("{0}",e[2]);u.appendChild(a(s.replace("{1}",e[3]),sa_CTBConfig.CT,i(r,"k"),o))}}function c(n,t,i,r){sa_CTBConfig.GenCapString&&r.appendChild(ht(sa_CTBConfig.GenCapString))}function l(n,t,r,f){var l=i(r,"h"),s,h,e,o,c;l&&(l.indexOf("START")>0?(s=sa_CTBConfig.PDSU,h=sa_CTBConfig.PDS):(s=sa_CTBConfig.PDEU,h=sa_CTBConfig.PDE),e=n.getElementsByTagName("h3")[0].childNodes[0].href,o=e.indexOf("//"),o>0&&(e=e.substring(o+2)),o=e.indexOf("/"),o>0&&(e=e.substring(0,o)),s=s.replace("{0}",encodeURIComponent(e)),c=a("#",h,i(r,"k")),c.onclick=function(n){return(new Image).src=s.replace("{1}",sj_cook.get("MUID","MUID")),u(n,!0)},f.appendChild(c))}function st(n){var n=sj_ev(n);return n&&(n.cancelBubble=!0),sj_pd(n),!1}function ht(n){var t=sj_ce("p");return t.innerText=t.textContent=n,t}function a(n,t,i,r){r===void 0&&(r=!1);var u=sj_ce("a");return u.href=n,u.innerText=u.textContent=t,r&&(u.target="_blank"),i&&sj_be(u,"mousedown",function(){return _w.si_T?_w.si_T("&ID="+i):null}),u}function ct(n,t,i){var r,o,u,f;if(typeof n=="string"){var t=t||_d,i=i||"*",e=t.getElementsByTagName(i),s=t.getElementsByClassName(sa_CTBConfig.staticIconClass);if(s.length==0)for(r=0,o=e.length;r<o;r++)if(u=e[r],f=u.className,f&&f.indexOf(n)!==-1)return u}}function lt(n){while(n&&!at(n,w))n=n.parentNode;return n}function at(n,t){if(n&&n.className)for(var i=0;i<t.length;i++)if(n.classList.contains(t[i]))return!0;return!1}function v(n,t,r){var o=typeof r=="undefined",f;if(n)for(f=0;f<n.childNodes.length;f++){var u=n.childNodes[f],s=i(u,t),e=o&&s||!o&&s==r?u:0;if(!e&&u.childNodes&&u.childNodes.length&&(e=v(u,t,r)),e)return e}return 0}function i(n,t){return n&&n.getAttribute?n.getAttribute(t):null}function vt(n){var t,r,f,e,u;n&&!n.tlbxLog&&(r=n.getElementsByTagName("h3"),r.length&&r[0].childNodes.length&&(f=r[0].childNodes[0],t=i(f,"h"),t||(e=i(f,"onmousedown"),e&&(u=e.toString().match(/(ID=[^']+)/i),u&&u.length>1&&(t=u[1])))),t&&(t=t.substring(t.indexOf("=")+1),(new Image).src=_G.lsUrl+'&Type=Event.ClientInst&DATA=[{"T":"CI.Hover","Name":"ToolboxOpen","K":"'+t+'","HType":"h"}]'),n.tlbxLog=1)}function yt(n,i,r){e||(e=pt(i));var u=sj_go(n.ti,"Left",r),f=_w.innerWidth-24-Math.round(n.ti.getBoundingClientRect().right),o=wt(u,f,e);switch(o){case t.FULLWIDTH:i.style.left="0px";i.style.right="0px";break;case t.RIGHT:i.style.right=f+"px";break;case t.LEFT:default:i.style.left=u+p()+"px"}i.style.top=sj_go(n.ti,"Top",r)+y()+"px"}function pt(n){var t=n.cloneNode(!0),i;return t.style.visibility="hidden",t.style.display="inline-block",_d.body.appendChild(t),i=t.offsetWidth,t.remove(),i}function wt(n,i,r){return r>n&&r>i?t.FULLWIDTH:_G.RTL?n>=r||n>i?t.RIGHT:t.LEFT:i>=r||i>n?t.LEFT:t.RIGHT}function bt(n){var t=sj_ce("div",null,"c_tlbxLiveRegion"),i;return(t.setAttribute("aria-live","polite"),t.setAttribute("aria-atomic","true"),i=n.querySelector(".b_attribution"),i)?(i.appendChild(t),n.toolboxPlaceholder=t,!0):!1}function y(){return o?19:9}function p(){return o?-15:-3}var f,w=["b_algo","b_ans"],b="BASE:CACHEDPAGEDEFAULT",k="BASE:PREFERDOMAINSTART",d="BASE:PREFERDOMAINSTOP",g="BASE:GENERATIVECAPTIONSHINTSIGNAL",nt="BASE:GENERATIVEQIHINTSIGNAL",r={},n,e=0,o=(f=_w.__enableGCloneAttribution)!==null&&f!==void 0?f:!1,t;(function(n){n.LEFT="left-align";n.RIGHT="right-align";n.FULLWIDTH="full-width"})(t||(t={}));tt()})(WebResultToolboxBlueV2||(WebResultToolboxBlueV2={}))