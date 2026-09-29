import svgPaths from "./svg-csztwuzupv";

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
        <g clipPath="url(#clip0_0_44)" id="Icon">
          <path d={svgPaths.p5b1c2f0} fill="#6B7280" id="Vector" />
          <path d={svgPaths.pfa93380} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p2cd646f0} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p10337c00} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_44">
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
        <g clipPath="url(#clip0_0_49)" id="Icon">
          <path d={svgPaths.p30c54b00} id="Vector" stroke="#6B7280" strokeWidth="0.999056" />
          <path d={svgPaths.p2391db00} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p20ca00c0} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_49">
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
  return <div className="absolute h-[7px] left-[-4px] rounded-[40822700px] top-[0.5px] w-[100px]" style={{ backgroundImage: "linear-gradient(175.9958270592906deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container" />;
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
    <div className="absolute content-stretch flex gap-[29px] h-[46px] items-center left-[24.26px] right-[-0.26px] top-[7.23px]">
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

function Icon2() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="Icon">
          <path d={svgPaths.p35d3c040} fill="white" fillOpacity="0.9" id="Vector" />
          <path d={svgPaths.p30a1e560} id="Vector_2" stroke="white" strokeLinecap="round" strokeWidth="1.83283" />
        </g>
      </svg>
    </div>
  );
}

function Container9() {
  return (
    <div className="content-stretch drop-shadow-[0px_10px_14px_rgba(79,126,245,0.3)] flex items-center justify-center relative rounded-[14px] shrink-0 size-[44px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Icon2 />
    </div>
  );
}

function Text1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] bg-clip-text font-['Roboto:ExtraBold',sans-serif] font-extrabold leading-[30px] relative shrink-0 text-[20px] text-[transparent] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100', backgroundImage: "linear-gradient(158.45902408146156deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }}>
        Careerly
      </p>
    </div>
  );
}

function Container8() {
  return (
    <div className="content-stretch flex gap-[12px] h-[76px] items-center pb-[32px] relative shrink-0 w-[342px]" data-name="Container">
      <Container9 />
      <Text1 />
    </div>
  );
}

function Heading() {
  return (
    <div className="content-stretch flex flex-col h-[80px] items-start pb-[8px] relative shrink-0 w-[342px]" data-name="Heading 1">
      <div className="[word-break:break-word] font-['Noto_Sans_SC:Black',sans-serif] font-black leading-[0] relative shrink-0 text-[#111827] text-[28px] whitespace-nowrap">
        <p className="leading-[36px] mb-0">看见你的能力，</p>
        <p className="leading-[36px]">找到下一步。</p>
      </div>
    </div>
  );
}

function ParagraphMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[32px] relative shrink-0 w-full" data-name="Paragraph:margin">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[0] not-italic relative shrink-0 text-[#6b7280] text-[14px] w-[343px]">
        <span className="font-['Roboto:Regular',sans-serif] leading-[22px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`Careerly `}</span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[22px]">帮你了解自己与目标岗位之间的距离，找到真正需要提升的能力，并记录每一次成长。</span>
      </p>
    </div>
  );
}

function Icon3() {
  return (
    <div className="relative shrink-0 size-[19.998px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="19.998" preserveAspectRatio="none" viewBox="0 0 19.998 19.998" width="19.998">
        <g clipPath="url(#clip0_0_55)" id="Icon">
          <path d={svgPaths.pe4ac980} id="Vector" stroke="#4F7EF5" strokeWidth="1.49985" />
          <path d={svgPaths.p3e8a5000} id="Vector_2" stroke="#4F7EF5" strokeLinecap="round" strokeWidth="1.49985" />
        </g>
        <defs>
          <clipPath id="clip0_0_55">
            <rect fill="white" height="19.998" width="19.998" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container12() {
  return (
    <div className="bg-[rgba(255,255,255,0.6)] content-stretch flex items-center justify-center relative rounded-[99px] shrink-0 size-[36px]" data-name="Container">
      <Icon3 />
    </div>
  );
}

function ContainerMargin() {
  return (
    <div className="absolute content-stretch flex items-start left-[16px] pt-[2px] top-[16px]" data-name="Container:margin">
      <Container12 />
    </div>
  );
}

function Paragraph() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 right-0 top-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] relative shrink-0 text-[#201e22] text-[14px] whitespace-nowrap">看见能力</p>
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 pt-[2px] top-[21px] w-[258px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#727272] text-[12px] w-[259px]">了解你已积累的职业能力，让优势变得可见。</p>
    </div>
  );
}

function Container13() {
  return (
    <div className="absolute h-[41px] left-[68.26px] top-[16.23px] w-[235px]" data-name="Container">
      <Paragraph />
      <Paragraph1 />
    </div>
  );
}

function Icon4() {
  return (
    <div className="absolute left-[5.51px] size-[12.983px] top-[5.51px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="12.9835" preserveAspectRatio="none" viewBox="0 0 12.9835 12.9835" width="12.9835">
        <g id="Icon">
          <path d={svgPaths.p204aa280} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.35245" />
        </g>
      </svg>
    </div>
  );
}

function Container14() {
  return (
    <div className="absolute bg-[#4f7ef5] left-[310.26px] rounded-[12px] size-[24px] top-[8.23px]" data-name="Container">
      <Icon4 />
    </div>
  );
}

function Container11() {
  return (
    <div className="bg-[rgba(167,123,230,0.5)] h-[73px] relative rounded-[16px] shrink-0 w-[342px]" data-name="Container">
      <ContainerMargin />
      <Container13 />
      <Container14 />
    </div>
  );
}

function Icon5() {
  return (
    <div className="relative shrink-0 size-[19.998px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="19.998" preserveAspectRatio="none" viewBox="0 0 19.998 19.998" width="19.998">
        <g clipPath="url(#clip0_0_37)" id="Icon">
          <path d={svgPaths.p3e2b7900} id="Vector" stroke="#A77BE6" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.49985" />
        </g>
        <defs>
          <clipPath id="clip0_0_37">
            <rect fill="white" height="19.998" width="19.998" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container16() {
  return (
    <div className="bg-[rgba(255,255,255,0.6)] content-stretch flex items-center justify-center relative rounded-[99px] shrink-0 size-[36px]" data-name="Container">
      <Icon5 />
    </div>
  );
}

function ContainerMargin2() {
  return (
    <div className="absolute content-stretch flex items-start left-[16px] pt-[2px] rounded-[99px] top-[16px]" data-name="Container:margin">
      <Container16 />
    </div>
  );
}

function Paragraph2() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[0] not-italic relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Bold',sans-serif] leading-[21px]">找到</span>
        <span className="font-['Roboto:Bold',sans-serif] leading-[21px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` Gap`}</span>
      </p>
    </div>
  );
}

function Paragraph3() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start pt-[2px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#6b7280] text-[12px] whitespace-nowrap">看见你与目标岗位之间的距离，知道差在哪里。</p>
    </div>
  );
}

function Container17() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[68px] top-[16px] w-[252px]" data-name="Container">
      <Paragraph2 />
      <Paragraph3 />
    </div>
  );
}

function Icon6() {
  return (
    <div className="relative shrink-0 size-[12.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="12.9835" preserveAspectRatio="none" viewBox="0 0 12.9835 12.9835" width="12.9835">
        <g id="Icon">
          <path d={svgPaths.p204aa280} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.35245" />
        </g>
      </svg>
    </div>
  );
}

function Container18() {
  return (
    <div className="absolute bg-[#a77be6] content-stretch flex items-center justify-center left-[311.26px] rounded-[12px] size-[24px] top-[8.23px]" data-name="Container">
      <Icon6 />
    </div>
  );
}

function Container15() {
  return (
    <div className="bg-[rgba(79,126,245,0.33)] h-[73px] relative rounded-[16px] shrink-0 w-full" data-name="Container">
      <ContainerMargin2 />
      <Container17 />
      <Container18 />
    </div>
  );
}

function ContainerMargin1() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0 w-full" data-name="Container:margin">
      <Container15 />
    </div>
  );
}

function Icon7() {
  return (
    <div className="relative shrink-0 size-[19.998px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="19.998" preserveAspectRatio="none" viewBox="0 0 19.998 19.998" width="19.998">
        <g clipPath="url(#clip0_0_53)" id="Icon">
          <path d={svgPaths.p2380800} id="Vector" stroke="#34C759" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.49985" />
        </g>
        <defs>
          <clipPath id="clip0_0_53">
            <rect fill="white" height="19.998" width="19.998" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container20() {
  return (
    <div className="bg-[rgba(255,255,255,0.6)] content-stretch flex items-center justify-center relative rounded-[99px] shrink-0 size-[36px]" data-name="Container">
      <Icon7 />
    </div>
  );
}

function ContainerMargin4() {
  return (
    <div className="absolute content-stretch flex items-start left-[16px] pt-[2px] top-[16px]" data-name="Container:margin">
      <Container20 />
    </div>
  );
}

function Paragraph4() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 right-0 top-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">持续成长</p>
    </div>
  );
}

function Paragraph5() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 pt-[2px] top-[21px] w-[258px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#6b7280] text-[12px] w-[259px]">每一次进步都被记录，见证真实的职业成长。</p>
    </div>
  );
}

function Container21() {
  return (
    <div className="absolute h-[41px] left-[68px] top-[16px] w-[258px]" data-name="Container">
      <Paragraph4 />
      <Paragraph5 />
    </div>
  );
}

function Icon8() {
  return (
    <div className="relative shrink-0 size-[12.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="12.9835" preserveAspectRatio="none" viewBox="0 0 12.9835 12.9835" width="12.9835">
        <g id="Icon">
          <path d={svgPaths.p204aa280} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.35245" />
        </g>
      </svg>
    </div>
  );
}

function Container22() {
  return (
    <div className="absolute bg-[#34c759] content-stretch flex items-center justify-center left-[311.26px] rounded-[12px] size-[24px] top-[6.23px]" data-name="Container">
      <Icon8 />
    </div>
  );
}

function Container19() {
  return (
    <div className="bg-[rgba(202,219,143,0.5)] h-[73px] relative rounded-[16px] shrink-0 w-full" data-name="Container">
      <ContainerMargin4 />
      <Container21 />
      <Container22 />
    </div>
  );
}

function ContainerMargin3() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0 w-[342px]" data-name="Container:margin">
      <Container19 />
    </div>
  );
}

function Container10() {
  return (
    <div className="content-stretch flex flex-[357_0_0] flex-col items-start min-h-px relative" data-name="Container">
      <Container11 />
      <ContainerMargin1 />
      <ContainerMargin3 />
    </div>
  );
}

function PrimaryBtn() {
  return (
    <div className="content-stretch drop-shadow-[0px_8px_12px_rgba(79,126,245,0.3)] flex h-[48px] items-center justify-center relative rounded-[99px] shrink-0 w-[342px]" style={{ backgroundImage: "linear-gradient(172.0106732336031deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="PrimaryBtn">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] relative shrink-0 text-[15px] text-center text-white whitespace-nowrap">开始建立我的职业画像</p>
    </div>
  );
}

function PrimaryBtnMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[12px] relative shrink-0" data-name="PrimaryBtn:margin">
      <PrimaryBtn />
    </div>
  );
}

function Button() {
  return (
    <div className="absolute h-[20px] left-0 top-[3.4px] w-[342px]" data-name="Button">
      <p className="-translate-x-1/2 [word-break:break-word] absolute font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[19.5px] left-[170.99px] text-[#6b7280] text-[13px] text-center top-[0.37px] whitespace-nowrap">稍后再说</p>
    </div>
  );
}

function Container24() {
  return (
    <div className="h-[24.007px] relative shrink-0 w-full" data-name="Container">
      <Button />
    </div>
  );
}

function Container23() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[24px] relative shrink-0 w-full" data-name="Container">
      <PrimaryBtnMargin />
      <Container24 />
    </div>
  );
}

function Container7() {
  return (
    <div className="absolute content-stretch flex flex-col h-[764px] items-start left-0 px-[24px] py-[32px] right-0 top-[46px]" data-name="Container">
      <Container8 />
      <Heading />
      <ParagraphMargin />
      <Container10 />
      <Container23 />
    </div>
  );
}

function Container4() {
  return (
    <div className="h-[810px] overflow-clip relative shrink-0 w-full" style={{ backgroundImage: "linear-gradient(142.91297317837098deg, rgb(238, 242, 255) 8.4861%, rgb(245, 243, 255) 50%, rgb(253, 244, 255) 91.514%)" }} data-name="Container">
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