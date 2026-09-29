import svgPaths from "./svg-g1kp6malug";

function Text() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:SemiBold',sans-serif] font-semibold leading-[19.5px] relative shrink-0 text-[#6b7280] text-[13px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        9:41
      </p>
    </div>
  );
}

function Icon() {
  return (
    <div className="h-[11.995px] relative shrink-0 w-[15.987px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.995" preserveAspectRatio="none" viewBox="0 0 15.987 11.995" width="15.987">
        <g clipPath="url(#clip0_0_61)" id="Icon">
          <path d={svgPaths.p5b1c2f0} fill="#6B7280" id="Vector" />
          <path d={svgPaths.pfa93380} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p2cd646f0} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p10337c00} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_61">
            <rect fill="white" height="11.995" width="15.987" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Icon1() {
  return (
    <div className="h-[11.995px] relative shrink-0 w-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.995" preserveAspectRatio="none" viewBox="0 0 17.983 11.995" width="17.983">
        <g clipPath="url(#clip0_0_57)" id="Icon">
          <path d={svgPaths.p30c54b00} id="Vector" stroke="#6B7280" strokeWidth="0.999056" />
          <path d={svgPaths.p2391db00} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p20ca00c0} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_57">
            <rect fill="white" height="11.995" width="17.983" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container2() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0" data-name="Container">
      <Icon />
      <Icon1 />
    </div>
  );
}

function Container1() {
  return (
    <div className="content-stretch flex items-center justify-between pb-[2px] pt-[12px] px-[24px] relative shrink-0 w-full" data-name="Container">
      <Text />
      <Container2 />
    </div>
  );
}

function Container5() {
  return <div className="absolute backdrop-blur-[28px] bg-[rgba(255,255,255,0.5)] h-[737px] left-[-1.22px] rounded-[24px] top-[-0.22px] w-[356px]" data-name="Container" />;
}

function Container8() {
  return <div className="relative rounded-[43.998px] shadow-[0px_0px_36.8px_0px_rgba(99,102,241,0.59)] shrink-0 size-[87.995px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(91, 124, 250) 0%, rgb(155, 93, 229) 60%, rgb(192, 132, 252) 100%)" }} data-name="Container" />;
}

function ContainerMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[16px] relative shrink-0" data-name="Container:margin">
      <Container8 />
    </div>
  );
}

function Paragraph() {
  return (
    <div className="content-stretch flex flex-col items-center max-w-[220px] pt-[6px] relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Plus_Jakarta_Sans:Regular',sans-serif] font-normal leading-[0] relative shrink-0 text-[#626579] text-[12px] text-center w-[220px]">
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[19.5px]">我是你的</span>
        <span className="font-['Roboto:Regular',sans-serif] leading-[19.5px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` AI `}</span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[19.5px]">职业顾问，可以帮你分析岗位、优化简历、制定求职策略。</span>
      </p>
    </div>
  );
}

function Container7() {
  return (
    <div className="absolute content-stretch flex flex-col items-center left-0 pb-[20px] pt-[24px] px-[20px] right-0 top-0" data-name="Container">
      <ContainerMargin />
      <p className="[word-break:break-word] font-['Plus_Jakarta_Sans:ExtraBold',sans-serif] font-extrabold leading-[0] relative shrink-0 text-[#171827] text-[16px] text-center whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Black',sans-serif] font-black leading-[24px]">你好，</span>
        <span className="font-['Roboto:ExtraBold',sans-serif] leading-[24px]" style={{ fontVariationSettings: '"wdth" 100' }}>
          ALEX
        </span>
      </p>
      <Paragraph />
    </div>
  );
}

function Container9() {
  return <div className="border-[rgba(99,91,219,0.1)] border-solid border-t-[1.217px] h-[1.217px] relative shrink-0 w-[315.596px]" data-name="Container" />;
}

function ContainerMargin1() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 px-[20px] top-[217px]" data-name="Container:margin">
      <Container9 />
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[20px] pb-[12px] pl-[4px] top-[16px] w-[315.596px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[16.5px] relative shrink-0 text-[#9ca3af] text-[11px] tracking-[0.275px] uppercase whitespace-nowrap">你可以问我</p>
    </div>
  );
}

function Icon2() {
  return (
    <div className="absolute inset-[19.23%_15.38%_19.22%_19.23%]" data-name="Icon">
      <div className="absolute inset-[-9.37%_-8.82%]">
        <svg className="block size-full" fill="none" height="9.48879" preserveAspectRatio="none" viewBox="0 0 9.98821 9.48879" width="9.98821">
          <g id="Icon">
            <path d={svgPaths.p38d25700} id="Vector" stroke="#635BDB" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.4981" />
          </g>
        </svg>
      </div>
    </div>
  );
}

function Image() {
  return (
    <div className="overflow-clip relative shrink-0 size-[12.984px]" data-name="Image">
      <Icon2 />
    </div>
  );
}

function Container12() {
  return (
    <div className="content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[27.982px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 250, 0.1) 0%, rgba(155, 93, 229, 0.1) 100%)" }} data-name="Container">
      <Image />
    </div>
  );
}

function Text1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Plus_Jakarta_Sans:Medium',sans-serif] font-medium leading-[0] relative shrink-0 text-[#171827] text-[12px] whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Medium',sans-serif] leading-[16px]">为什么这个岗位匹配度只有</span>
        <span className="font-['Roboto:Medium',sans-serif] leading-[16px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` 82%`}</span>
        <span className="font-['Noto_Sans_SC:Medium',sans-serif] leading-[16px]">？</span>
      </p>
    </div>
  );
}

function Button() {
  return (
    <div className="bg-[rgba(255,255,255,0.7)] border-[1.217px] border-[rgba(91,124,250,0.14)] border-solid content-stretch flex gap-[12px] items-center p-[14px] relative rounded-[16px] shadow-[0px_2px_10px_0px_rgba(99,91,219,0.05)] shrink-0 w-[315.596px]" data-name="Button">
      <Container12 />
      <Text1 />
    </div>
  );
}

function Icon3() {
  return (
    <div className="absolute inset-[19.23%_15.38%_19.22%_19.23%]" data-name="Icon">
      <div className="absolute inset-[-9.37%_-8.82%]">
        <svg className="block size-full" fill="none" height="9.48879" preserveAspectRatio="none" viewBox="0 0 9.98821 9.48879" width="9.98821">
          <g id="Icon">
            <path d={svgPaths.p38d25700} id="Vector" stroke="#635BDB" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.4981" />
          </g>
        </svg>
      </div>
    </div>
  );
}

function Image1() {
  return (
    <div className="overflow-clip relative shrink-0 size-[12.984px]" data-name="Image">
      <Icon3 />
    </div>
  );
}

function Container13() {
  return (
    <div className="content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[27.982px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 250, 0.1) 0%, rgba(155, 93, 229, 0.1) 100%)" }} data-name="Container">
      <Image1 />
    </div>
  );
}

function Text2() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[16px] relative shrink-0 text-[#171827] text-[12px] whitespace-nowrap">帮我优化这个项目的描述</p>
    </div>
  );
}

function Button1() {
  return (
    <div className="bg-[rgba(255,255,255,0.7)] border-[1.217px] border-[rgba(91,124,250,0.14)] border-solid content-stretch flex gap-[12px] items-center p-[14px] relative rounded-[16px] shadow-[0px_2px_10px_0px_rgba(99,91,219,0.05)] shrink-0 w-[315.596px]" data-name="Button">
      <Container13 />
      <Text2 />
    </div>
  );
}

function Icon4() {
  return (
    <div className="absolute inset-[19.23%_15.38%_19.22%_19.23%]" data-name="Icon">
      <div className="absolute inset-[-9.37%_-8.82%]">
        <svg className="block size-full" fill="none" height="9.48879" preserveAspectRatio="none" viewBox="0 0 9.98821 9.48879" width="9.98821">
          <g id="Icon">
            <path d={svgPaths.p38d25700} id="Vector" stroke="#635BDB" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.4981" />
          </g>
        </svg>
      </div>
    </div>
  );
}

function Image2() {
  return (
    <div className="overflow-clip relative shrink-0 size-[12.984px]" data-name="Image">
      <Icon4 />
    </div>
  );
}

function Container14() {
  return (
    <div className="content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[27.982px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 250, 0.1) 0%, rgba(155, 93, 229, 0.1) 100%)" }} data-name="Container">
      <Image2 />
    </div>
  );
}

function Text3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[16px] relative shrink-0 text-[#171827] text-[12px] whitespace-nowrap">我目前最需要提升什么能力？</p>
    </div>
  );
}

function Button2() {
  return (
    <div className="bg-[rgba(255,255,255,0.7)] border-[1.217px] border-[rgba(91,124,250,0.14)] border-solid content-stretch flex gap-[12px] items-center p-[14px] relative rounded-[16px] shadow-[0px_2px_10px_0px_rgba(99,91,219,0.05)] shrink-0 w-[315.596px]" data-name="Button">
      <Container14 />
      <Text3 />
    </div>
  );
}

function Icon5() {
  return (
    <div className="absolute inset-[19.23%_15.38%_19.22%_19.23%]" data-name="Icon">
      <div className="absolute inset-[-9.37%_-8.82%]">
        <svg className="block size-full" fill="none" height="9.48879" preserveAspectRatio="none" viewBox="0 0 9.98821 9.48879" width="9.98821">
          <g id="Icon">
            <path d={svgPaths.p38d25700} id="Vector" stroke="#635BDB" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.4981" />
          </g>
        </svg>
      </div>
    </div>
  );
}

function Image3() {
  return (
    <div className="overflow-clip relative shrink-0 size-[12.984px]" data-name="Image">
      <Icon5 />
    </div>
  );
}

function Container15() {
  return (
    <div className="content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[27.982px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 250, 0.1) 0%, rgba(155, 93, 229, 0.1) 100%)" }} data-name="Container">
      <Image3 />
    </div>
  );
}

function Text4() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[16px] relative shrink-0 text-[#171827] text-[12px] whitespace-nowrap">下一步我应该做什么？</p>
    </div>
  );
}

function Button3() {
  return (
    <div className="bg-[rgba(255,255,255,0.7)] border-[1.217px] border-[rgba(91,124,250,0.14)] border-solid content-stretch flex gap-[12px] items-center p-[14px] relative rounded-[16px] shadow-[0px_2px_10px_0px_rgba(99,91,219,0.05)] shrink-0 w-[315.596px]" data-name="Button">
      <Container15 />
      <Text4 />
    </div>
  );
}

function Container11() {
  return (
    <div className="absolute content-stretch flex flex-col gap-[8px] items-start left-[20px] top-[45px]" data-name="Container">
      <Button />
      <Button1 />
      <Button2 />
      <Button3 />
    </div>
  );
}

function Container10() {
  return (
    <div className="absolute h-[303px] left-0 right-0 top-[223px]" data-name="Container">
      <Paragraph1 />
      <Container11 />
    </div>
  );
}

function Container6() {
  return (
    <div className="absolute h-[531px] left-[-0.22px] overflow-clip top-[-0.22px] w-[356px]" data-name="Container">
      <Container7 />
      <ContainerMargin1 />
      <Container10 />
    </div>
  );
}

function Container4() {
  return (
    <div className="absolute bg-[rgba(255,255,255,0)] border-[1.217px] border-[rgba(255,255,255,0.82)] border-solid h-[738px] left-[16.26px] overflow-clip rounded-[24px] shadow-[0px_8px_40px_0px_rgba(91,124,250,0.16)] top-[66.23px] w-[357px]" data-name="Container">
      <Container5 />
      <Container6 />
    </div>
  );
}

function PlaceholderForAiPageMargin() {
  return <div className="h-[582px] relative shrink-0 w-[86px]" data-name="Placeholder for AIPage:margin" />;
}

function FillShadow() {
  return (
    <div className="absolute inset-0 rounded-[1000px] shadow-[1.25px_0px_0px_-0.75px_#d0d0d0,-1.25px_0px_0px_-0.75px_#d0d0d0,0px_0px_0px_0.5px_#e8e8e8,0px_8px_15px_0px_rgba(0,0,0,0.02)]" data-name="Fill + Shadow">
      <div aria-hidden className="absolute inset-0 pointer-events-none rounded-[1000px]">
        <div className="absolute inset-0 rounded-[1000px]" style={{ backgroundImage: "linear-gradient(90deg, rgba(255, 255, 255, 0.25) 0%, rgba(255, 255, 255, 0.25) 100%), linear-gradient(90deg, rgba(0, 0, 0, 0.25) 0%, rgba(0, 0, 0, 0.25) 100%)" }} />
        <div className="absolute bg-[rgba(68,68,68,0.6)] inset-0 mix-blend-plus-lighter rounded-[1000px]" />
        <div className="absolute bg-[rgba(248,248,248,0.2)] inset-0 mix-blend-luminosity rounded-[1000px]" />
      </div>
    </div>
  );
}

function GlassEffect() {
  return (
    <div className="absolute inset-0 pointer-events-none rounded-[1000px]" data-name="Glass Effect">
      <div aria-hidden className="absolute bg-[rgba(0,0,0,0)] inset-0 rounded-[1000px]" />
      <div className="absolute inset-0 rounded-[inherit] shadow-[inset_0px_40px_10px_-40px_#282828,inset_0px_-40px_10px_-40px_#282828,inset_0px_40px_30px_-40px_#e6e6e6]" />
    </div>
  );
}

function Container18() {
  return <div className="bg-[#00bc7d] relative rounded-[2.994px] shadow-[0px_0px_5px_0px_rgba(16,185,129,0.9)] shrink-0 size-[5.988px]" data-name="Container" />;
}

function Paragraph2() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Plus_Jakarta_Sans:Regular',sans-serif] font-normal leading-[0] relative shrink-0 text-[#626579] text-[11px] whitespace-nowrap">
        <span className="font-['Roboto:Regular',sans-serif] leading-[16.5px]" style={{ fontVariationSettings: '"wdth" 100' }}>
          AI
        </span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[16.5px]">职业顾问</span>
        <span className="font-['Roboto:Regular',sans-serif] leading-[16.5px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` · `}</span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[16.5px]">在线</span>
      </p>
    </div>
  );
}

function Container17() {
  return (
    <div className="absolute content-stretch flex gap-[4px] items-center left-0 pt-[2px] top-[20px]" data-name="Container">
      <Container18 />
      <Paragraph2 />
    </div>
  );
}

function Container16() {
  return (
    <div className="h-[39px] relative shrink-0 w-[94.988px]" data-name="Container">
      <p className="[word-break:break-word] absolute font-['Roboto:Bold',sans-serif] font-bold leading-[20px] left-[1.99px] text-[#171827] text-[14px] top-0 whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        Career Copilot
      </p>
      <Container17 />
    </div>
  );
}

function FillShadow1() {
  return (
    <div className="absolute inset-0 rounded-[1000px] shadow-[1.25px_0px_0px_-0.75px_#d0d0d0,-1.25px_0px_0px_-0.75px_#d0d0d0,0px_0px_0px_0.5px_#e8e8e8,0px_8px_15px_0px_rgba(0,0,0,0.02)]" data-name="Fill + Shadow">
      <div aria-hidden className="absolute inset-0 pointer-events-none rounded-[1000px]">
        <div className="absolute inset-0 rounded-[1000px]" style={{ backgroundImage: "linear-gradient(90deg, rgba(255, 255, 255, 0.25) 0%, rgba(255, 255, 255, 0.25) 100%), linear-gradient(90deg, rgba(0, 0, 0, 0.25) 0%, rgba(0, 0, 0, 0.25) 100%)" }} />
        <div className="absolute bg-[rgba(68,68,68,0.6)] inset-0 mix-blend-plus-lighter rounded-[1000px]" />
        <div className="absolute bg-[rgba(248,248,248,0.2)] inset-0 mix-blend-luminosity rounded-[1000px]" />
      </div>
    </div>
  );
}

function GlassEffect1() {
  return (
    <div className="absolute inset-0 pointer-events-none rounded-[1000px]" data-name="Glass Effect">
      <div aria-hidden className="absolute bg-[rgba(0,0,0,0)] inset-0 rounded-[1000px]" />
      <div className="absolute inset-0 rounded-[inherit] shadow-[inset_0px_40px_10px_-40px_#282828,inset_0px_-40px_10px_-40px_#282828,inset_0px_40px_30px_-40px_#e6e6e6]" />
    </div>
  );
}

function AiHeader() {
  return (
    <div className="-translate-x-1/2 absolute content-stretch flex gap-[83px] items-center left-[calc(50%+0.26px)] px-[20px] py-[12px] top-[0.23px] w-[390px]" data-name="AIHeader">
      <div className="h-[44px] min-w-[44px] relative rounded-[296px] shrink-0" data-name="Button Group">
        <div className="flex flex-row items-center justify-center min-w-[inherit] size-full">
          <div className="content-stretch flex gap-[12px] items-center justify-center min-w-[inherit] px-[2px] relative size-full">
            <div className="-translate-y-1/2 absolute h-[44px] left-0 right-0 top-1/2" data-name="BG">
              <FillShadow />
              <GlassEffect />
            </div>
            <div className="h-[36px] min-w-[36px] relative rounded-[100px] shrink-0" data-name="Text">
              <div className="flex flex-row items-center justify-center min-w-[inherit] size-full">
                <div className="content-stretch flex gap-[2px] items-center justify-center min-w-[inherit] px-[8px] relative size-full">
                  <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Semibold',sans-serif] font-[590] justify-center leading-[0] relative shrink-0 text-[#08f] text-[17px] text-center whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100', fontFeatureSettings: '"ss16" 1' }}>
                    <p className="leading-[normal]">{`\u{100BF6}`}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <Container16 />
      <div className="h-[44px] relative rounded-[296px] shrink-0" data-name="Button">
        <div className="flex flex-row items-center size-full">
          <div className="content-stretch flex gap-[20px] items-center px-[4px] relative size-full">
            <div className="-translate-y-1/2 absolute h-[44px] left-0 right-0 top-1/2" data-name="BG">
              <FillShadow1 />
              <GlassEffect1 />
            </div>
            <div className="relative rounded-[100px] shrink-0 size-[36px]" data-name="Symbol 1">
              <div className="content-stretch flex flex-col items-start relative size-full">
                <div className="[word-break:break-word] flex flex-[1_0_0] flex-col font-['SF_Pro:Medium',sans-serif] font-[510] justify-center leading-[0] min-h-px relative text-[#08f] text-[17px] text-center w-full" style={{ fontVariationSettings: '"wdth" 100', fontFeatureSettings: '"ss16" 1' }}>
                  <p className="leading-[normal]">{`\u{1003DA}`}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function Frame() {
  return (
    <div className="absolute h-[31.993px] left-[16px] top-[13.78px] w-[32.993px]">
      <div className="absolute inset-[0_-2.5%_0_0]">
        <svg className="block size-full" fill="none" height="31.9931" preserveAspectRatio="none" viewBox="0 0 33.8181 31.9931" width="33.8181">
          <g id="Frame 1814106303">
            <g id="Container">
              <path d={svgPaths.p1a65d980} id="Vector" stroke="#D3CEF4" strokeLinecap="round" strokeWidth="1.65" />
            </g>
            <path d="M32.9931 4.74653V27.2465" id="Vector_2" stroke="#D3CEF4" strokeLinecap="round" strokeOpacity="0.5" strokeWidth="1.65" />
          </g>
        </svg>
      </div>
    </div>
  );
}

function TextInput() {
  return (
    <div className="absolute content-stretch flex flex-col h-[22px] items-start justify-center left-[0.05px] overflow-clip top-[-2.77px] w-[202px]" data-name="Text Input">
      <p className="[word-break:break-word] font-['Plus_Jakarta_Sans:Regular',sans-serif] font-normal leading-[0] relative shrink-0 text-[12px] text-[rgba(17,24,39,0.5)] w-full">
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[normal]">输入你想问的问题</span>
        <span className="font-['Roboto:Regular',sans-serif] leading-[normal]" style={{ fontVariationSettings: '"wdth" 100' }}>
          ...
        </span>
      </p>
    </div>
  );
}

function Container20() {
  return (
    <div className="absolute h-[15.987px] left-[57.99px] overflow-clip top-[21.78px] w-[201.625px]" data-name="Container">
      <TextInput />
    </div>
  );
}

function Icon6() {
  return (
    <div className="absolute inset-[18.75%_12.5%]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="9.99208" preserveAspectRatio="none" viewBox="0 0 11.9905 9.99208" width="11.9905">
        <g id="Icon">
          <path d={svgPaths.p2d733e80} fill="#635BDB" fillOpacity="0.4" id="Vector" />
        </g>
      </svg>
    </div>
  );
}

function Image4() {
  return (
    <div className="opacity-50 overflow-clip relative shrink-0 size-[15.987px]" data-name="Image">
      <Icon6 />
    </div>
  );
}

function Button4() {
  return (
    <div className="absolute bg-[rgba(99,91,219,0.1)] content-stretch flex items-center justify-center left-[269.62px] rounded-[12px] size-[35.985px] top-[11.79px]" data-name="Button">
      <Image4 />
    </div>
  );
}

function Container19() {
  return (
    <div className="absolute backdrop-blur-[20px] bg-[rgba(255,255,255,0.72)] border-[1.217px] border-[rgba(255,255,255,0.88)] border-solid h-[61.99px] left-[30.26px] rounded-[99px] shadow-[0px_4px_24px_0px_rgba(91,124,250,0.13)] top-[69.23px] w-[324.037px]" data-name="Container">
      <Frame />
      <Container20 />
      <Button4 />
    </div>
  );
}

function AiInputBar() {
  return (
    <div className="h-[139px] relative shrink-0 w-[366px]" data-name="AIInputBar">
      <Container19 />
    </div>
  );
}

function AiPage() {
  return (
    <div className="content-stretch flex flex-col h-[810.491px] items-start relative shrink-0 w-full" data-name="AIPage">
      <Container4 />
      <PlaceholderForAiPageMargin />
      <AiHeader />
      <AiInputBar />
    </div>
  );
}

function Container3() {
  return (
    <div className="content-stretch flex flex-[810.491_0_0] flex-col items-start min-h-px overflow-clip relative w-full" data-name="Container">
      <AiPage />
    </div>
  );
}

function Container23() {
  return <div className="absolute bg-[rgba(255,255,255,0.18)] border-[1.217px] border-[rgba(255,255,255,0.35)] border-solid h-[64.404px] left-[-0.99px] rounded-[31px] top-[-0.99px] w-[236.346px]" data-name="Container" />;
}

function IconHome() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="IconHome">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="IconHome">
          <path d={svgPaths.p15f7f580} id="Vector" stroke="#7B7979" strokeLinejoin="round" strokeWidth="1.55791" />
        </g>
      </svg>
    </div>
  );
}

function Button5() {
  return (
    <div className="content-stretch flex h-[49.995px] items-center justify-center relative rounded-[22px] shrink-0 w-[71.989px]" data-name="Button">
      <IconHome />
    </div>
  );
}

function IconChart() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="IconChart">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="IconChart">
          <path d={svgPaths.p264d8d00} fill="#7B7979" id="Vector" />
          <path d={svgPaths.p3374c200} fill="#7B7979" id="Vector_2" />
          <path d={svgPaths.p2e91c100} fill="#7B7979" id="Vector_3" />
        </g>
      </svg>
    </div>
  );
}

function Button6() {
  return (
    <div className="content-stretch flex h-[50px] items-center justify-center relative rounded-[22px] shrink-0 w-[72px]" data-name="Button">
      <IconChart />
    </div>
  );
}

function IconUser() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="IconUser">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="IconUser">
          <path d={svgPaths.p35d3c040} id="Vector" stroke="#7B7979" strokeWidth="1.55791" />
          <path d={svgPaths.p36c37e00} id="Vector_2" stroke="#7B7979" strokeLinecap="round" strokeWidth="1.55791" />
        </g>
      </svg>
    </div>
  );
}

function Button7() {
  return (
    <div className="content-stretch flex h-[50px] items-center justify-center relative rounded-[22px] shrink-0 w-[72px]" data-name="Button">
      <IconUser />
    </div>
  );
}

function Container24() {
  return (
    <div className="absolute content-stretch flex gap-[2px] items-center left-0 px-[6px] py-[5px] rounded-[30px] top-0" data-name="Container">
      <div aria-hidden className="absolute backdrop-blur-[10px] bg-[rgba(255,255,255,0.04)] inset-0 pointer-events-none rounded-[30px]" />
      <div aria-hidden className="absolute border-[1.217px] border-[rgba(255,255,255,0.3)] border-solid inset-0 pointer-events-none rounded-[30px] shadow-[0px_6px_24px_0px_rgba(0,0,0,0.08),0px_1px_4px_0px_rgba(0,0,0,0.04)]" />
      <Button5 />
      <Button6 />
      <Button7 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.62),inset_0px_-1px_0px_0px_rgba(255,255,255,0.12),inset_1px_0px_0px_0px_rgba(255,255,255,0.18),inset_-1px_0px_0px_0px_rgba(255,255,255,0.1)]" />
    </div>
  );
}

function Container22() {
  return (
    <div className="h-[62.427px] relative rounded-[30px] shrink-0 w-[234.369px]" data-name="Container">
      <Container23 />
      <Container24 />
    </div>
  );
}

function Text5() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Regular','Noto_Sans:Regular','Noto_Sans_Math:Regular','Noto_Sans_Symbols:Regular','Noto_Sans_Symbols2:Regular',sans-serif] font-normal leading-[24px] relative shrink-0 text-[22px] text-center text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        ✦
      </p>
    </div>
  );
}

function Text6() {
  return (
    <div className="content-stretch flex flex-col items-center pt-[2px] relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[13.5px] relative shrink-0 text-[9px] text-[rgba(255,255,255,0.92)] text-center whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        AI
      </p>
    </div>
  );
}

function Button8() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center relative rounded-[99px] shrink-0 size-[62px]" data-name="Button">
      <div aria-hidden className="absolute backdrop-blur-[10px] inset-0 pointer-events-none rounded-[99px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(79, 126, 245, 0.72) 0%, rgba(167, 123, 230, 0.72) 100%)" }} />
      <div aria-hidden className="absolute border-[1.217px] border-[rgba(255,255,255,0.42)] border-solid inset-0 pointer-events-none rounded-[99px] shadow-[0px_8px_24px_0px_rgba(79,126,245,0.3),0px_2px_6px_0px_rgba(0,0,0,0.06)]" />
      <Text5 />
      <Text6 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.5),inset_0px_-1px_0px_0px_rgba(79,126,245,0.2)]" />
    </div>
  );
}

function Container21() {
  return (
    <div className="absolute content-stretch flex gap-[10px] items-center justify-center left-0 pb-[20px] pt-[8px] top-[753.58px] w-[390px]" data-name="Container">
      <Container22 />
      <Button8 />
    </div>
  );
}

function Container() {
  return (
    <div className="content-stretch flex flex-col h-[843.986px] items-start max-h-[844px] max-w-[390px] overflow-clip relative shrink-0 w-[390px]" style={{ backgroundImage: "linear-gradient(110.2948550978526deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container1 />
      <Container3 />
      <Container21 />
    </div>
  );
}

function App() {
  return (
    <div className="bg-[#d2def0] content-stretch flex h-[873.526px] items-center justify-center relative shrink-0 w-[401.481px]" data-name="App">
      <Container />
    </div>
  );
}

export default function CareerlyAppInterfaceDesignCopy() {
  return (
    <div className="bg-white content-stretch flex flex-col items-start relative size-full" data-name="Careerly App Interface Design (Copy)">
      <App />
    </div>
  );
}