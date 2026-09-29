import svgPaths from "./svg-36wpqtfq6f";

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
        <g clipPath="url(#clip0_0_45)" id="Icon">
          <path d={svgPaths.p5b1c2f0} fill="#6B7280" id="Vector" />
          <path d={svgPaths.pfa93380} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p2cd646f0} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p10337c00} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_45">
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
        <g clipPath="url(#clip0_0_35)" id="Icon">
          <path d={svgPaths.p30c54b00} id="Vector" stroke="#6B7280" strokeWidth="0.999056" />
          <path d={svgPaths.p2391db00} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p20ca00c0} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_35">
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

function Container6() {
  return <div className="absolute h-[7px] left-[-3.74px] rounded-[40822700px] top-[-0.27px] w-[150px]" style={{ backgroundImage: "linear-gradient(177.32813540672743deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container" />;
}

function Container5() {
  return (
    <div className="bg-[rgba(79,126,245,0.12)] h-[7px] overflow-clip relative rounded-[40822700px] shrink-0 w-[200px]" data-name="Container">
      <Container6 />
    </div>
  );
}

function Frame() {
  return (
    <div className="content-stretch flex gap-[29px] h-[62px] items-center pl-[30px] pr-[16px] py-[7px] relative shrink-0 w-[372px]">
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
      <Container5 />
    </div>
  );
}

function Heading() {
  return (
    <div className="content-stretch flex flex-col h-[34px] items-start relative shrink-0 w-full" data-name="Heading 1">
      <p className="[word-break:break-word] font-['Inter:Extra_Bold',sans-serif] font-extrabold leading-[0] not-italic relative shrink-0 text-[#111827] text-[26px] whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Black',sans-serif] font-black leading-[34px]">让</span>
        <span className="font-['Roboto:ExtraBold',sans-serif] leading-[34px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` Careerly `}</span>
        <span className="font-['Noto_Sans_SC:Black',sans-serif] font-black leading-[34px]">认识你的经历</span>
      </p>
    </div>
  );
}

function Heading1Margin() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[8px] relative shrink-0 w-full" data-name="Heading 1:margin">
      <Heading />
    </div>
  );
}

function Paragraph() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[0] not-italic relative shrink-0 text-[#6b7280] text-[13px] whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[20px]">上传简历，</span>
        <span className="font-['Roboto:Regular',sans-serif] leading-[20px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`AI `}</span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[20px]">会自动整理你的职业资产。</span>
      </p>
    </div>
  );
}

function ParagraphMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[24px] relative shrink-0 w-full" data-name="Paragraph:margin">
      <Paragraph />
    </div>
  );
}

function Icon2() {
  return (
    <div className="relative shrink-0 size-[25.986px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="25.986" preserveAspectRatio="none" viewBox="0 0 25.986 25.986" width="25.986">
        <g id="Icon">
          <path d={svgPaths.p36c28900} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.1655" />
          <path d={svgPaths.p61e03c0} id="Vector_2" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.1655" />
          <path d="M12.993 3.24825V16.2412" id="Vector_3" stroke="white" strokeLinecap="round" strokeWidth="2.1655" />
        </g>
      </svg>
    </div>
  );
}

function Container9() {
  return (
    <div className="content-stretch drop-shadow-[0px_10px_12px_rgba(79,126,245,0.28)] flex items-center justify-center relative rounded-[18px] shrink-0 size-[60px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Icon2 />
    </div>
  );
}

function ContainerMargin1() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[16px] relative shrink-0" data-name="Container:margin">
      <Container9 />
    </div>
  );
}

function ParagraphMargin1() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[4px] relative shrink-0" data-name="Paragraph:margin">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] relative shrink-0 text-[#111827] text-[15px] whitespace-nowrap">上传简历</p>
    </div>
  );
}

function Container8() {
  return (
    <div className="backdrop-blur-[12px] bg-[rgba(255,255,255,0.65)] border-[1.217px] border-[rgba(79,126,245,0.28)] border-dashed content-stretch flex flex-col h-[203.433px] items-center justify-center py-[40px] relative rounded-[24px] shrink-0 w-full" data-name="Container">
      <ContainerMargin1 />
      <ParagraphMargin1 />
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[0] not-italic relative shrink-0 text-[#6b7280] text-[12px] whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[18px]">支持</span>
        <span className="font-['Roboto:Regular',sans-serif] leading-[18px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` PDF / DOCX `}</span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[18px]">格式</span>
      </p>
    </div>
  );
}

function ContainerMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[20px] relative shrink-0 w-full" data-name="Container:margin">
      <Container8 />
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[0] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">
        <span className="font-['Roboto:SemiBold',sans-serif] leading-[16.5px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`AI `}</span>
        <span className="font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[16.5px]">将自动为你提取</span>
      </p>
    </div>
  );
}

function Icon3() {
  return (
    <div className="relative shrink-0 size-[7.984px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="7.98401" preserveAspectRatio="none" viewBox="0 0 7.98401 7.98401" width="7.98401">
        <g clipPath="url(#clip0_0_39)" id="Icon">
          <path d={svgPaths.p3c49d700} id="Vector" stroke="#4F7EF5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.06453" />
        </g>
        <defs>
          <clipPath id="clip0_0_39">
            <rect fill="white" height="7.98401" width="7.98401" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container13() {
  return (
    <div className="bg-[rgba(79,126,245,0.12)] content-stretch flex items-center justify-center relative rounded-[40822700px] shrink-0 size-[16px]" data-name="Container">
      <Icon3 />
    </div>
  );
}

function Text1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#111827] text-[12px] whitespace-nowrap">工作经历</p>
    </div>
  );
}

function Container12() {
  return (
    <div className="col-1 content-stretch flex gap-[8px] items-center justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Container">
      <Container13 />
      <Text1 />
    </div>
  );
}

function Icon4() {
  return (
    <div className="relative shrink-0 size-[7.984px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="7.98401" preserveAspectRatio="none" viewBox="0 0 7.98401 7.98401" width="7.98401">
        <g clipPath="url(#clip0_0_39)" id="Icon">
          <path d={svgPaths.p3c49d700} id="Vector" stroke="#4F7EF5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.06453" />
        </g>
        <defs>
          <clipPath id="clip0_0_39">
            <rect fill="white" height="7.98401" width="7.98401" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container15() {
  return (
    <div className="bg-[rgba(79,126,245,0.12)] content-stretch flex items-center justify-center relative rounded-[40822700px] shrink-0 size-[16px]" data-name="Container">
      <Icon4 />
    </div>
  );
}

function Text2() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#111827] text-[12px] whitespace-nowrap">项目经历</p>
    </div>
  );
}

function Container14() {
  return (
    <div className="col-2 content-stretch flex gap-[8px] items-center justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Container">
      <Container15 />
      <Text2 />
    </div>
  );
}

function Icon5() {
  return (
    <div className="relative shrink-0 size-[7.984px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="7.98401" preserveAspectRatio="none" viewBox="0 0 7.98401 7.98401" width="7.98401">
        <g clipPath="url(#clip0_0_39)" id="Icon">
          <path d={svgPaths.p3c49d700} id="Vector" stroke="#4F7EF5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.06453" />
        </g>
        <defs>
          <clipPath id="clip0_0_39">
            <rect fill="white" height="7.98401" width="7.98401" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container17() {
  return (
    <div className="bg-[rgba(79,126,245,0.12)] content-stretch flex items-center justify-center relative rounded-[40822700px] shrink-0 size-[16px]" data-name="Container">
      <Icon5 />
    </div>
  );
}

function Text3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#111827] text-[12px] whitespace-nowrap">技能与能力</p>
    </div>
  );
}

function Container16() {
  return (
    <div className="col-1 content-stretch flex gap-[8px] items-center justify-self-stretch relative row-2 self-stretch shrink-0" data-name="Container">
      <Container17 />
      <Text3 />
    </div>
  );
}

function Icon6() {
  return (
    <div className="relative shrink-0 size-[7.984px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="7.98401" preserveAspectRatio="none" viewBox="0 0 7.98401 7.98401" width="7.98401">
        <g clipPath="url(#clip0_0_39)" id="Icon">
          <path d={svgPaths.p3c49d700} id="Vector" stroke="#4F7EF5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.06453" />
        </g>
        <defs>
          <clipPath id="clip0_0_39">
            <rect fill="white" height="7.98401" width="7.98401" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container19() {
  return (
    <div className="bg-[rgba(79,126,245,0.12)] content-stretch flex items-center justify-center relative rounded-[40822700px] shrink-0 size-[16px]" data-name="Container">
      <Icon6 />
    </div>
  );
}

function Text4() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#111827] text-[12px] whitespace-nowrap">教育背景</p>
    </div>
  );
}

function Container18() {
  return (
    <div className="col-2 content-stretch flex gap-[8px] items-center justify-self-stretch relative row-2 self-stretch shrink-0" data-name="Container">
      <Container19 />
      <Text4 />
    </div>
  );
}

function Icon7() {
  return (
    <div className="relative shrink-0 size-[7.984px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="7.98401" preserveAspectRatio="none" viewBox="0 0 7.98401 7.98401" width="7.98401">
        <g clipPath="url(#clip0_0_39)" id="Icon">
          <path d={svgPaths.p3c49d700} id="Vector" stroke="#4F7EF5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.06453" />
        </g>
        <defs>
          <clipPath id="clip0_0_39">
            <rect fill="white" height="7.98401" width="7.98401" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container21() {
  return (
    <div className="bg-[rgba(79,126,245,0.12)] content-stretch flex items-center justify-center relative rounded-[40822700px] shrink-0 size-[16px]" data-name="Container">
      <Icon7 />
    </div>
  );
}

function Text5() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#111827] text-[12px] whitespace-nowrap">奖项与证书</p>
    </div>
  );
}

function Container20() {
  return (
    <div className="col-1 content-stretch flex gap-[8px] items-center justify-self-stretch relative row-3 self-stretch shrink-0" data-name="Container">
      <Container21 />
      <Text5 />
    </div>
  );
}

function Container11() {
  return (
    <div className="gap-y-[8px] grid grid-cols-[__155.02px_155.02px] grid-rows-[___17.98px_17.98px_17.98px] h-[70px] relative shrink-0 w-full" data-name="Container">
      <Container12 />
      <Container14 />
      <Container16 />
      <Container18 />
      <Container20 />
    </div>
  );
}

function ContainerMargin3() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[10px] relative shrink-0 w-full" data-name="Container:margin">
      <Container11 />
    </div>
  );
}

function Container10() {
  return (
    <div className="bg-[rgba(255,255,255,0.55)] content-stretch flex flex-col h-[121px] items-start px-[16px] py-[12px] relative rounded-[16px] shrink-0 w-full" data-name="Container">
      <Paragraph1 />
      <ContainerMargin3 />
    </div>
  );
}

function ContainerMargin2() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[16px] relative shrink-0 w-full" data-name="Container:margin">
      <Container10 />
    </div>
  );
}

function Paragraph2() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] relative shrink-0 text-[#6b7280] text-[11px] text-center whitespace-nowrap">你的数据仅用于分析，不会对外泄露</p>
    </div>
  );
}

function ParagraphMargin2() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[4px] relative shrink-0 w-full" data-name="Paragraph:margin">
      <Paragraph2 />
    </div>
  );
}

function PrimaryBtn() {
  return (
    <div className="content-stretch drop-shadow-[0px_8px_12px_rgba(79,126,245,0.3)] flex h-[48px] items-center justify-center relative rounded-[99px] shrink-0 w-[342px]" style={{ backgroundImage: "linear-gradient(172.0106732336031deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="PrimaryBtn">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] relative shrink-0 text-[15px] text-center text-white whitespace-nowrap">选择文件</p>
    </div>
  );
}

function SecondaryBtn() {
  return (
    <div className="bg-[rgba(79,126,245,0.08)] content-stretch flex h-[48px] items-center justify-center relative rounded-[99px] shrink-0 w-[342px]" data-name="SecondaryBtn">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] relative shrink-0 text-[#4f7ef5] text-[14px] text-center whitespace-nowrap">粘贴简历文本</p>
    </div>
  );
}

function SecondaryBtnMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0" data-name="SecondaryBtn:margin">
      <SecondaryBtn />
    </div>
  );
}

function Container22() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[16px] relative shrink-0 w-full" data-name="Container">
      <PrimaryBtn />
      <SecondaryBtnMargin />
    </div>
  );
}

function Container7() {
  return (
    <div className="content-stretch flex flex-[761_0_0] flex-col items-start min-h-px px-[24px] py-[32px] relative w-full" data-name="Container">
      <Heading1Margin />
      <ParagraphMargin />
      <ContainerMargin />
      <ContainerMargin2 />
      <ParagraphMargin2 />
      <Container22 />
    </div>
  );
}

function Container4() {
  return (
    <div className="content-stretch flex flex-col h-[810px] items-start overflow-clip relative shrink-0 w-full" style={{ backgroundImage: "linear-gradient(142.91297317837098deg, rgb(238, 242, 255) 8.4861%, rgb(245, 243, 255) 50%, rgb(253, 244, 255) 91.514%)" }} data-name="Container">
      <Frame />
      <Container7 />
    </div>
  );
}

function Container3() {
  return (
    <div className="content-stretch flex flex-[810.491_0_0] flex-col items-start min-h-px overflow-clip relative w-full" data-name="Container">
      <Container4 />
    </div>
  );
}

function Container() {
  return (
    <div className="content-stretch flex flex-col h-[843.986px] items-start max-h-[844px] max-w-[390px] overflow-clip relative shrink-0 w-[390px]" style={{ backgroundImage: "linear-gradient(110.2948550978526deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container1 />
      <Container3 />
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