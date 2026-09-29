import svgPaths from "./svg-g0ckyofkgh";
import imgImage33 from "./c61cbc031dbdc1169262d5946824c2890e8b11f4.png";

function Text() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[19.5px] not-italic relative shrink-0 text-[#6b7280] text-[13px] whitespace-nowrap">9:41</p>
    </div>
  );
}

function Icon() {
  return (
    <div className="h-[11.99px] relative shrink-0 w-[15.998px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.9895" preserveAspectRatio="none" viewBox="0 0 15.9984 11.9895" width="15.9984">
        <g clipPath="url(#clip0_0_13)" id="Icon">
          <path d={svgPaths.p19238df0} fill="#6B7280" id="Vector" />
          <path d={svgPaths.p1d305000} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p37739680} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p1b5f3f80} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_13">
            <rect fill="white" height="11.9895" width="15.9984" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Icon1() {
  return (
    <div className="h-[11.99px] relative shrink-0 w-[17.984px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.9895" preserveAspectRatio="none" viewBox="0 0 17.9843 11.9895" width="17.9843">
        <g clipPath="url(#clip0_0_49)" id="Icon">
          <path d={svgPaths.pa04fc80} id="Vector" stroke="#6B7280" strokeWidth="0.999125" />
          <path d={svgPaths.p9a4ab80} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p7154300} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_49">
            <rect fill="white" height="11.9895" width="17.9843" />
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
    <div className="absolute content-stretch flex h-[34px] items-center justify-between left-0 pb-[2px] pt-[12px] px-[24px] right-0 top-0" data-name="Container">
      <Text />
      <Container2 />
    </div>
  );
}

function Frame5() {
  return (
    <div className="bg-white h-[27px] overflow-clip relative shrink-0 w-[109px]">
      <div className="absolute h-[137px] left-[-70.74px] top-[-46.21px] w-[205px]" data-name="image 33">
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <img alt="" className="absolute left-[12.23%] max-w-none size-full top-[-17.73%]" src={imgImage33} />
        </div>
      </div>
    </div>
  );
}

function Icon2() {
  return (
    <div className="relative shrink-0 size-[16.982px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="16.982" preserveAspectRatio="none" viewBox="0 0 16.982 16.982" width="16.982">
        <g clipPath="url(#clip0_0_35)" id="Icon">
          <path d={svgPaths.pa346f80} id="Vector" stroke="#515151" strokeWidth="1.27365" />
          <path d={svgPaths.p370a2bc0} id="Vector_2" stroke="#515151" strokeWidth="1.27365" />
        </g>
        <defs>
          <clipPath id="clip0_0_35">
            <rect fill="white" height="16.982" width="16.982" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Button() {
  return (
    <div className="backdrop-blur-[16px] bg-[rgba(255,255,255,0.45)] border-[1.188px] border-[rgba(255,255,255,0.4)] border-solid content-stretch flex items-center justify-center relative rounded-[99px] shadow-[0px_4px_16px_0px_rgba(79,126,245,0.05)] shrink-0 size-[40px]" data-name="Button">
      <Icon2 />
    </div>
  );
}

function Header() {
  return (
    <div className="content-stretch flex h-[60px] items-center justify-between pb-[12px] pt-[16px] px-[24px] relative shrink-0 w-full" data-name="header">
      <Frame5 />
      <Button />
    </div>
  );
}

function Text1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[33px] not-italic relative shrink-0 text-[28px] text-white whitespace-nowrap">A</p>
    </div>
  );
}

function Container5() {
  return (
    <div className="content-stretch drop-shadow-[0px_8px_12px_rgba(79,126,245,0.3)] flex items-center justify-center relative rounded-[99px] shrink-0 size-[96px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Text1 />
    </div>
  );
}

function AvatarSection() {
  return (
    <div className="content-stretch flex flex-col items-center py-[12px] relative shrink-0 w-full" data-name="avatar-section">
      <Header />
      <Container5 />
    </div>
  );
}

function NameGroup() {
  return (
    <div className="[word-break:break-word] content-stretch flex flex-col gap-[2px] items-start leading-[normal] not-italic relative shrink-0 whitespace-nowrap" data-name="name-group">
      <p className="font-['Inter:Bold',sans-serif] font-bold relative shrink-0 text-[#181a20] text-[18px]">Alex</p>
      <p className="font-['Inter:Regular',sans-serif] font-normal relative shrink-0 text-[#6e717c] text-[12px]">@elmasekeri</p>
    </div>
  );
}

function Crown() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="crown">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_38)" id="crown">
          <path d={svgPaths.p3a726dc0} id="Vector" stroke="#F2C94C" strokeLinecap="round" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_38">
            <rect fill="white" height="12" width="12" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function PremiumBadge() {
  return (
    <div className="bg-[#373b4d] content-stretch flex gap-[4px] items-center px-[12px] py-[6px] relative rounded-[100px] shrink-0" data-name="premium-badge">
      <Crown />
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[normal] not-italic relative shrink-0 text-[11px] text-white whitespace-nowrap">V1会员</p>
    </div>
  );
}

function ProfileMetaRow() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full" data-name="profile-meta-row">
      <NameGroup />
      <PremiumBadge />
    </div>
  );
}

function Frame() {
  return (
    <div className="[word-break:break-word] content-stretch flex flex-[1_0_0] flex-col gap-[4px] items-center leading-[normal] min-w-px not-italic relative whitespace-nowrap" data-name="Frame">
      <p className="font-['Inter:Extra_Bold',sans-serif] font-extrabold relative shrink-0 text-[#181a20] text-[16px]">4</p>
      <p className="font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold relative shrink-0 text-[#6e717c] text-[11px]">简历版本</p>
    </div>
  );
}

function Frame1() {
  return (
    <div className="[word-break:break-word] content-stretch flex flex-[1_0_0] flex-col gap-[4px] items-center leading-[normal] min-w-px not-italic relative whitespace-nowrap" data-name="Frame">
      <p className="font-['Inter:Extra_Bold',sans-serif] font-extrabold relative shrink-0 text-[#181a20] text-[16px]">22</p>
      <p className="font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold relative shrink-0 text-[#6e717c] text-[11px]">分析岗位</p>
    </div>
  );
}

function Frame2() {
  return (
    <div className="[word-break:break-word] content-stretch flex flex-[1_0_0] flex-col gap-[4px] items-center leading-[normal] min-w-px not-italic relative whitespace-nowrap" data-name="Frame">
      <p className="font-['Inter:Extra_Bold',sans-serif] font-extrabold relative shrink-0 text-[#181a20] text-[16px]">15</p>
      <p className="font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold relative shrink-0 text-[#6e717c] text-[11px]">分析次数</p>
    </div>
  );
}

function StatsRow() {
  return (
    <div className="content-stretch flex items-start justify-between py-[4px] relative shrink-0 w-full" data-name="stats-row">
      <Frame />
      <div className="flex h-[28px] items-center justify-center relative shrink-0 w-0">
        <div className="flex-none rotate-90">
          <div className="h-0 relative w-[28px]" data-name="Line">
            <div className="absolute inset-[-1px_0_0_0]">
              <svg className="block size-full" fill="none" height="1" preserveAspectRatio="none" viewBox="0 0 28 1" width="28">
                <line id="Line" stroke="#121212" strokeOpacity="0.0823529" x2="28" y1="0.5" y2="0.5" />
              </svg>
            </div>
          </div>
        </div>
      </div>
      <Frame1 />
      <div className="flex h-[28px] items-center justify-center relative shrink-0 w-0">
        <div className="flex-none rotate-90">
          <div className="h-0 relative w-[28px]" data-name="Line">
            <div className="absolute inset-[-1px_0_0_0]">
              <svg className="block size-full" fill="none" height="1" preserveAspectRatio="none" viewBox="0 0 28 1" width="28">
                <line id="Line" stroke="#121212" strokeOpacity="0.0823529" x2="28" y1="0.5" y2="0.5" />
              </svg>
            </div>
          </div>
        </div>
      </div>
      <Frame2 />
    </div>
  );
}

function Frame4() {
  return (
    <div className="[word-break:break-word] absolute content-stretch flex flex-col gap-[2px] h-[29px] items-start leading-[normal] left-[24px] not-italic top-0 w-[136px] whitespace-nowrap" data-name="Frame">
      <p className="font-['Inter:Bold',sans-serif] font-bold overflow-hidden relative shrink-0 text-[12px] text-ellipsis text-white">Careerly Pro</p>
      <p className="font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal overflow-hidden relative shrink-0 text-[#f4f5fc] text-[10px] text-ellipsis">免费体验剩余 3/3 次 · 无限分析 AI 顾问</p>
    </div>
  );
}

function Text2() {
  return (
    <div className="absolute h-[30px] left-[3px] top-0 w-[18px]" data-name="Text">
      <p className="[word-break:break-word] absolute font-['Inter:Regular','Noto_Sans:Regular','Noto_Sans_Math:Regular','Noto_Sans_Symbols:Regular','Noto_Sans_Symbols2:Regular',sans-serif] font-normal leading-[30px] left-0 not-italic text-[#f2c94c] text-[20px] top-0 whitespace-nowrap">✦</p>
    </div>
  );
}

function Frame3() {
  return (
    <div className="absolute h-[29px] left-0 top-0 w-[160px]" data-name="Frame">
      <Frame4 />
      <Text2 />
    </div>
  );
}

function Frame6() {
  return (
    <div className="absolute h-[29px] left-[7.26px] top-[12.29px] w-[278px]">
      <Frame3 />
    </div>
  );
}

function Container6() {
  return (
    <div className="h-[53px] overflow-clip relative rounded-[16px] shrink-0 w-full" style={{ backgroundImage: "linear-gradient(170.046144289311deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Frame6 />
    </div>
  );
}

function InfoCard() {
  return (
    <div className="bg-[rgba(255,255,255,0.68)] content-stretch flex flex-col gap-[16px] items-start p-[20px] relative rounded-[24px] shrink-0 w-full" data-name="info-card">
      <div aria-hidden className="absolute border-[1.5px] border-[rgba(255,255,255,0.23)] border-solid inset-0 pointer-events-none rounded-[24px] shadow-[0px_12px_24px_0px_rgba(155,177,201,0.25)]" />
      <ProfileMetaRow />
      <StatsRow />
      <Container6 />
    </div>
  );
}

function UserInfoContainer() {
  return (
    <div className="content-stretch flex flex-col h-[216px] items-start px-[24px] py-[8px] relative shrink-0 w-full" data-name="user-info-container">
      <InfoCard />
    </div>
  );
}

function TabActive() {
  return (
    <div className="bg-[#373b4d] content-stretch flex items-start px-[16px] py-[10px] relative rounded-[20px] shrink-0" data-name="Tab Active">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[14px] text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        职业资产
      </p>
    </div>
  );
}

function TabInactive() {
  return (
    <div className="bg-white content-stretch flex items-start px-[16px] py-[10px] relative rounded-[20px] shrink-0" data-name="Tab Inactive">
      <div aria-hidden className="absolute border border-[#eaeafa] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Roboto:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[normal] relative shrink-0 text-[14px] text-[rgba(30,31,34,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        成长足迹
      </p>
    </div>
  );
}

function TabInactive1() {
  return (
    <div className="bg-white content-stretch flex items-start px-[16px] py-[10px] relative rounded-[20px] shrink-0" data-name="Tab Inactive">
      <div aria-hidden className="absolute border border-[#eaeafa] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Roboto:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[normal] relative shrink-0 text-[14px] text-[rgba(30,31,34,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        我的简历
      </p>
    </div>
  );
}

function TabInactive2() {
  return (
    <div className="bg-white content-stretch flex items-start px-[16px] py-[10px] relative rounded-[20px] shrink-0" data-name="Tab Inactive">
      <div aria-hidden className="absolute border border-[#eaeafa] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Roboto:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[normal] relative shrink-0 text-[14px] text-[rgba(30,31,34,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        历史分析
      </p>
    </div>
  );
}

function TabInactive3() {
  return (
    <div className="bg-white content-stretch flex items-start px-[16px] py-[10px] relative rounded-[20px] shrink-0" data-name="Tab Inactive">
      <div aria-hidden className="absolute border border-[#eaeafa] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Roboto:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[normal] relative shrink-0 text-[14px] text-[rgba(30,31,34,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        设置
      </p>
    </div>
  );
}

function FilterTabs() {
  return (
    <div className="content-stretch flex gap-[12px] items-start overflow-clip pl-[30px] pr-[20px] py-[16px] relative shrink-0 w-[366px]" data-name="Filter Tabs">
      <TabActive />
      <TabInactive />
      <TabInactive1 />
      <TabInactive2 />
      <TabInactive3 />
    </div>
  );
}

function Text3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Regular',sans-serif] font-normal leading-[27px] relative shrink-0 text-[18px] text-black whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        ⭐
      </p>
    </div>
  );
}

function Container10() {
  return (
    <div className="bg-[rgba(255,255,255,0.18)] content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[40px]" data-name="Container">
      <Text3 />
    </div>
  );
}

function Paragraph() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 right-0 top-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[19.5px] not-italic relative shrink-0 text-[13px] text-white whitespace-nowrap">职业资产</p>
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="absolute content-stretch flex flex-col h-[19px] items-start left-0 pt-[2px] right-0 top-[20px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[11px] text-[rgba(255,255,255,0.65)] whitespace-nowrap">本月新增 1 项 · AI 能力 +8</p>
    </div>
  );
}

function Container11() {
  return (
    <div className="h-[39px] relative shrink-0 w-[179px]" data-name="Container">
      <Paragraph />
      <Paragraph1 />
    </div>
  );
}

function Text4() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[16.5px] not-italic relative shrink-0 text-[11px] text-center text-white whitespace-nowrap">{` 查看全部`}</p>
    </div>
  );
}

function Icon3() {
  return (
    <div className="relative shrink-0 size-[11.99px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.9895" preserveAspectRatio="none" viewBox="0 0 11.9895 11.9895" width="11.9895">
        <g id="Icon">
          <path d={svgPaths.p4968e80} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.09904" />
        </g>
      </svg>
    </div>
  );
}

function Button1() {
  return (
    <div className="bg-[rgba(255,255,255,0.15)] content-stretch flex gap-[4px] items-center px-[10px] py-[5px] relative rounded-[22px] shrink-0" data-name="Button">
      <Text4 />
      <Icon3 />
    </div>
  );
}

function Container9() {
  return (
    <div className="absolute content-stretch flex h-[68px] items-center justify-between left-0 pb-[12px] pt-[16px] px-[16px] right-0 top-0" data-name="Container">
      <Container10 />
      <Container11 />
      <Button1 />
    </div>
  );
}

function Icon4() {
  return (
    <div className="relative shrink-0 size-[16.982px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="16.982" preserveAspectRatio="none" viewBox="0 0 16.982 16.982" width="16.982">
        <g clipPath="url(#clip0_0_20)" id="Icon">
          <path d={svgPaths.p25b6da80} id="Vector" stroke="white" strokeWidth="1.20289" />
          <path d={svgPaths.p9f90180} id="Vector_2" stroke="white" strokeLinecap="round" strokeWidth="1.20289" />
        </g>
        <defs>
          <clipPath id="clip0_0_20">
            <rect fill="white" height="16.982" width="16.982" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container13() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Container">
      <Icon4 />
    </div>
  );
}

function Text5() {
  return (
    <div className="absolute h-[12px] left-[12.93px] top-[6.88px] w-[10px]" data-name="Text">
      <p className="[word-break:break-word] absolute font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[22px] left-0 not-italic text-[10px] text-white top-[-5px] whitespace-nowrap">段</p>
    </div>
  );
}

function Paragraph2() {
  return (
    <div className="h-[24px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] absolute font-['Inter:Extra_Bold',sans-serif] font-extrabold leading-[22px] left-[0.23px] not-italic text-[17px] text-white top-[-0.09px] whitespace-nowrap">4</p>
      <Text5 />
    </div>
  );
}

function ParagraphMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[8px] relative shrink-0 w-full" data-name="Paragraph:margin">
      <Paragraph2 />
    </div>
  );
}

function Paragraph3() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[55.501px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[10px] text-[rgba(255,255,255,0.7)] whitespace-nowrap">工作经历</p>
    </div>
  );
}

function Button2() {
  return (
    <div className="bg-[rgba(255,255,255,0.15)] content-stretch flex flex-col h-[73px] items-start justify-center pb-[10px] pt-[11px] px-[10px] relative rounded-[14px] shrink-0 w-[75.501px]" data-name="Button">
      <Container13 />
      <ParagraphMargin />
      <Paragraph3 />
    </div>
  );
}

function Icon5() {
  return (
    <div className="relative shrink-0 size-[16.982px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="16.982" preserveAspectRatio="none" viewBox="0 0 16.982 16.982" width="16.982">
        <g id="Icon">
          <path d={svgPaths.p2f03d000} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.20289" />
        </g>
      </svg>
    </div>
  );
}

function Container14() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Container">
      <Icon5 />
    </div>
  );
}

function Text6() {
  return (
    <div className="absolute h-[12px] left-[12.46px] top-[6.88px] w-[10px]" data-name="Text">
      <p className="[word-break:break-word] absolute font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[22px] left-0 not-italic text-[10px] text-white top-[-5px] whitespace-nowrap">个</p>
    </div>
  );
}

function Paragraph4() {
  return (
    <div className="h-[24px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] absolute font-['Inter:Extra_Bold',sans-serif] font-extrabold leading-[22px] left-[0.23px] not-italic text-[17px] text-white top-[-0.09px] whitespace-nowrap">6</p>
      <Text6 />
    </div>
  );
}

function ParagraphMargin1() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[8px] relative shrink-0 w-full" data-name="Paragraph:margin">
      <Paragraph4 />
    </div>
  );
}

function Paragraph5() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[55.519px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[10px] text-[rgba(255,255,255,0.7)] whitespace-nowrap">项目</p>
    </div>
  );
}

function Button3() {
  return (
    <div className="bg-[rgba(255,255,255,0.15)] content-stretch flex flex-col h-[73px] items-start justify-center pb-[10px] pt-[11px] px-[10px] relative rounded-[14px] shrink-0 w-[75.519px]" data-name="Button">
      <Container14 />
      <ParagraphMargin1 />
      <Paragraph5 />
    </div>
  );
}

function Icon6() {
  return (
    <div className="relative shrink-0 size-[16.982px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="16.982" preserveAspectRatio="none" viewBox="0 0 16.982 16.982" width="16.982">
        <g id="Icon">
          <path d={svgPaths.p1403a400} id="Vector" stroke="white" strokeLinejoin="round" strokeWidth="1.20289" />
        </g>
      </svg>
    </div>
  );
}

function Container15() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Container">
      <Icon6 />
    </div>
  );
}

function Paragraph6() {
  return (
    <div className="[word-break:break-word] h-[24px] leading-[22px] not-italic relative shrink-0 text-white w-full whitespace-nowrap" data-name="Paragraph">
      <p className="absolute font-['Inter:Extra_Bold',sans-serif] font-extrabold left-[0.23px] text-[17px] top-[-0.09px]">12</p>
      <p className="absolute font-['Inter:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium left-[19.57px] text-[10px] top-[1.88px]">项</p>
    </div>
  );
}

function ParagraphMargin2() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[8px] relative shrink-0 w-full" data-name="Paragraph:margin">
      <Paragraph6 />
    </div>
  );
}

function Paragraph7() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[55.501px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[10px] text-[rgba(255,255,255,0.7)] whitespace-nowrap">技能</p>
    </div>
  );
}

function Button4() {
  return (
    <div className="bg-[rgba(255,255,255,0.15)] content-stretch flex flex-col h-[73px] items-start justify-center pb-[10px] pt-[11px] px-[10px] relative rounded-[14px] shrink-0 w-[75.501px]" data-name="Button">
      <Container15 />
      <ParagraphMargin2 />
      <Paragraph7 />
    </div>
  );
}

function Icon7() {
  return (
    <div className="relative shrink-0 size-[16.982px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="16.982" preserveAspectRatio="none" viewBox="0 0 16.982 16.982" width="16.982">
        <g id="Icon">
          <path d={svgPaths.p2a09dfc0} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.20289" />
        </g>
      </svg>
    </div>
  );
}

function Container16() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Container">
      <Icon7 />
    </div>
  );
}

function Text7() {
  return (
    <div className="absolute h-[12px] left-[12.38px] top-[6.88px] w-[10px]" data-name="Text">
      <p className="[word-break:break-word] absolute font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[22px] left-0 not-italic text-[10px] text-white top-[-5px] whitespace-nowrap">个</p>
    </div>
  );
}

function Paragraph8() {
  return (
    <div className="h-[24px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] absolute font-['Inter:Extra_Bold',sans-serif] font-extrabold leading-[22px] left-[0.23px] not-italic text-[17px] text-white top-[-0.09px] whitespace-nowrap">3</p>
      <Text7 />
    </div>
  );
}

function ParagraphMargin3() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[8px] relative shrink-0 w-full" data-name="Paragraph:margin">
      <Paragraph8 />
    </div>
  );
}

function Paragraph9() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[55.519px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[10px] text-[rgba(255,255,255,0.7)] whitespace-nowrap">奖项</p>
    </div>
  );
}

function Button5() {
  return (
    <div className="bg-[rgba(255,255,255,0.15)] content-stretch flex flex-col h-[73px] items-start justify-center pb-[10px] pt-[11px] px-[10px] relative rounded-[14px] shrink-0 w-[75.519px]" data-name="Button">
      <Container16 />
      <ParagraphMargin3 />
      <Paragraph9 />
    </div>
  );
}

function Container12() {
  return (
    <div className="-translate-x-1/2 absolute content-stretch flex gap-[8px] items-center left-1/2 px-[12px] top-[68px]" data-name="Container">
      <Button2 />
      <Button3 />
      <Button4 />
      <Button5 />
    </div>
  );
}

function Container8() {
  return (
    <div className="h-[156px] overflow-clip relative rounded-[24px] shadow-[0px_8px_24px_0px_rgba(79,126,245,0.25)] shrink-0 w-full" style={{ backgroundImage: "linear-gradient(155.97678420183027deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Container9 />
      <Container12 />
    </div>
  );
}

function Container7() {
  return (
    <div className="content-stretch flex flex-col h-[156px] items-start px-[20px] relative shrink-0 w-[390px]" data-name="Container">
      <Container8 />
    </div>
  );
}

function Heading() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Heading 2">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[24px] not-italic relative shrink-0 text-[#111827] text-[16px] whitespace-nowrap">我的职业成长</p>
    </div>
  );
}

function Button6() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center relative shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] text-center whitespace-nowrap">查看全部 →</p>
    </div>
  );
}

function Container18() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full" data-name="Container">
      <Heading />
      <Button6 />
    </div>
  );
}

function Text8() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[19.5px] not-italic relative shrink-0 text-[#111827] text-[13px] whitespace-nowrap">2026年8月</p>
    </div>
  );
}

function Container22() {
  return <div className="bg-[#4f7ef5] relative rounded-[39856500px] shrink-0 size-[6px]" data-name="Container" />;
}

function Text9() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[13.5px] not-italic relative shrink-0 text-[#6b7280] text-[9px] whitespace-nowrap">分析</p>
    </div>
  );
}

function Container21() {
  return (
    <div className="content-stretch flex gap-[2px] items-center relative self-stretch shrink-0" data-name="Container">
      <Container22 />
      <Text9 />
    </div>
  );
}

function Container24() {
  return <div className="bg-[#a77be6] relative rounded-[39856500px] shrink-0 size-[6px]" data-name="Container" />;
}

function Text10() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[13.5px] not-italic relative shrink-0 text-[#6b7280] text-[9px] whitespace-nowrap">简历</p>
    </div>
  );
}

function Container23() {
  return (
    <div className="content-stretch flex gap-[2px] items-center relative self-stretch shrink-0" data-name="Container">
      <Container24 />
      <Text10 />
    </div>
  );
}

function Container26() {
  return <div className="bg-[#34c759] relative rounded-[39856500px] shrink-0 size-[6px]" data-name="Container" />;
}

function Text11() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[13.5px] not-italic relative shrink-0 text-[#6b7280] text-[9px] whitespace-nowrap">项目</p>
    </div>
  );
}

function Container25() {
  return (
    <div className="content-stretch flex gap-[2px] items-center relative self-stretch shrink-0" data-name="Container">
      <Container26 />
      <Text11 />
    </div>
  );
}

function Container28() {
  return <div className="bg-[#ff9500] relative rounded-[39856500px] shrink-0 size-[6px]" data-name="Container" />;
}

function Text12() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[13.5px] not-italic relative shrink-0 text-[#6b7280] text-[9px] whitespace-nowrap">能力</p>
    </div>
  );
}

function Container27() {
  return (
    <div className="content-stretch flex gap-[2px] items-center relative self-stretch shrink-0" data-name="Container">
      <Container28 />
      <Text12 />
    </div>
  );
}

function Container20() {
  return (
    <div className="content-stretch flex gap-[4px] items-start relative shrink-0" data-name="Container">
      <Container21 />
      <Container23 />
      <Container25 />
      <Container27 />
    </div>
  );
}

function Container19() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full" data-name="Container">
      <Text8 />
      <Container20 />
    </div>
  );
}

function Container30() {
  return (
    <div className="col-1 content-stretch flex flex-col items-center justify-self-stretch pb-[4px] relative row-1 self-stretch shrink-0" data-name="Container">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">一</p>
    </div>
  );
}

function Container31() {
  return (
    <div className="col-2 content-stretch flex flex-col items-center justify-self-stretch pb-[4px] relative row-1 self-stretch shrink-0" data-name="Container">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">二</p>
    </div>
  );
}

function Container32() {
  return (
    <div className="col-3 content-stretch flex flex-col items-center justify-self-stretch pb-[4px] relative row-1 self-stretch shrink-0" data-name="Container">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">三</p>
    </div>
  );
}

function Container33() {
  return (
    <div className="col-4 content-stretch flex flex-col items-center justify-self-stretch pb-[4px] relative row-1 self-stretch shrink-0" data-name="Container">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">四</p>
    </div>
  );
}

function Container34() {
  return (
    <div className="col-5 content-stretch flex flex-col items-center justify-self-stretch pb-[4px] relative row-1 self-stretch shrink-0" data-name="Container">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">五</p>
    </div>
  );
}

function Container35() {
  return (
    <div className="col-6 content-stretch flex flex-col items-center justify-self-stretch pb-[4px] relative row-1 self-stretch shrink-0" data-name="Container">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">六</p>
    </div>
  );
}

function Container36() {
  return (
    <div className="col-7 content-stretch flex flex-col items-center justify-self-stretch pb-[4px] relative row-1 self-stretch shrink-0" data-name="Container">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">日</p>
    </div>
  );
}

function Container29() {
  return (
    <div className="grid grid-cols-[_______45.08px_45.10px_45.08px_45.10px_45.08px_45.10px_45.10px] grid-rows-[_18.99px] h-[19px] relative shrink-0 w-full" data-name="Container">
      <Container30 />
      <Container31 />
      <Container32 />
      <Container33 />
      <Container34 />
      <Container35 />
      <Container36 />
    </div>
  );
}

function ContainerMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0 w-full" data-name="Container:margin">
      <Container29 />
    </div>
  );
}

function Container38() {
  return <div className="col-1 justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Container" />;
}

function Container39() {
  return <div className="col-2 justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Container" />;
}

function Container40() {
  return <div className="col-3 justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Container" />;
}

function Container41() {
  return <div className="col-4 justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Container" />;
}

function Container42() {
  return <div className="col-5 justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Container" />;
}

function Container43() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button7() {
  return (
    <div className="col-6 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-1 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">1</p>
      <Container43 />
    </div>
  );
}

function Container44() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button8() {
  return (
    <div className="col-7 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-1 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">2</p>
      <Container44 />
    </div>
  );
}

function Container45() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button9() {
  return (
    <div className="col-1 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-2 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">3</p>
      <Container45 />
    </div>
  );
}

function Container46() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button10() {
  return (
    <div className="col-2 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-2 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">4</p>
      <Container46 />
    </div>
  );
}

function Container47() {
  return <div className="bg-[#a77be6] relative rounded-[39856500px] shrink-0 size-[4px]" data-name="Container" />;
}

function Button11() {
  return (
    <div className="col-3 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-2 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">5</p>
      <Container47 />
    </div>
  );
}

function Container48() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button12() {
  return (
    <div className="col-4 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-2 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">6</p>
      <Container48 />
    </div>
  );
}

function Container49() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button13() {
  return (
    <div className="col-5 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-2 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">7</p>
      <Container49 />
    </div>
  );
}

function Container50() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button14() {
  return (
    <div className="col-6 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-2 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">8</p>
      <Container50 />
    </div>
  );
}

function Container51() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button15() {
  return (
    <div className="col-7 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-2 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">9</p>
      <Container51 />
    </div>
  );
}

function Container52() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button16() {
  return (
    <div className="col-1 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-3 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">10</p>
      <Container52 />
    </div>
  );
}

function Container53() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button17() {
  return (
    <div className="col-2 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-3 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">11</p>
      <Container53 />
    </div>
  );
}

function Container54() {
  return <div className="bg-[#4f7ef5] relative rounded-[39856500px] shrink-0 size-[4px]" data-name="Container" />;
}

function Button18() {
  return (
    <div className="col-3 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-3 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">12</p>
      <Container54 />
    </div>
  );
}

function Container55() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button19() {
  return (
    <div className="col-4 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-3 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">13</p>
      <Container55 />
    </div>
  );
}

function Container56() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button20() {
  return (
    <div className="col-5 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-3 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">14</p>
      <Container56 />
    </div>
  );
}

function Container57() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button21() {
  return (
    <div className="col-6 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-3 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">15</p>
      <Container57 />
    </div>
  );
}

function Container58() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button22() {
  return (
    <div className="col-7 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-3 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">16</p>
      <Container58 />
    </div>
  );
}

function Container59() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button23() {
  return (
    <div className="col-1 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-4 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">17</p>
      <Container59 />
    </div>
  );
}

function Container60() {
  return <div className="bg-[#ff9500] relative rounded-[39856500px] shrink-0 size-[4px]" data-name="Container" />;
}

function Button24() {
  return (
    <div className="col-2 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-4 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">18</p>
      <Container60 />
    </div>
  );
}

function Container61() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button25() {
  return (
    <div className="col-3 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-4 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">19</p>
      <Container61 />
    </div>
  );
}

function Container62() {
  return <div className="bg-[#34c759] relative rounded-[39856500px] shrink-0 size-[4px]" data-name="Container" />;
}

function Button26() {
  return (
    <div className="col-4 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-4 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">20</p>
      <Container62 />
    </div>
  );
}

function Container63() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button27() {
  return (
    <div className="col-5 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-4 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">21</p>
      <Container63 />
    </div>
  );
}

function Container64() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button28() {
  return (
    <div className="col-6 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-4 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">22</p>
      <Container64 />
    </div>
  );
}

function Container65() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button29() {
  return (
    <div className="col-7 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-4 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">23</p>
      <Container65 />
    </div>
  );
}

function Container66() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button30() {
  return (
    <div className="col-1 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-5 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">24</p>
      <Container66 />
    </div>
  );
}

function Container67() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button31() {
  return (
    <div className="col-2 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-5 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">25</p>
      <Container67 />
    </div>
  );
}

function Container68() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button32() {
  return (
    <div className="col-3 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-5 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">26</p>
      <Container68 />
    </div>
  );
}

function Container69() {
  return <div className="bg-[#a77be6] relative rounded-[39856500px] shrink-0 size-[4px]" data-name="Container" />;
}

function Button33() {
  return (
    <div className="col-4 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-5 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">27</p>
      <Container69 />
    </div>
  );
}

function Container70() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button34() {
  return (
    <div className="col-5 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-5 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">28</p>
      <Container70 />
    </div>
  );
}

function Container71() {
  return <div className="bg-[rgba(255,255,255,0.8)] relative rounded-[39856500px] shrink-0 size-[4px]" data-name="Container" />;
}

function Button35() {
  return (
    <div className="col-6 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-5 self-stretch shrink-0" style={{ backgroundImage: "linear-gradient(152.0009795238043deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[18px] not-italic relative shrink-0 text-[12px] text-center text-white whitespace-nowrap">29</p>
      <Container71 />
    </div>
  );
}

function Container72() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button36() {
  return (
    <div className="bg-[rgba(79,126,245,0.08)] col-7 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-5 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] text-center whitespace-nowrap">30</p>
      <Container72 />
    </div>
  );
}

function Container73() {
  return <div className="h-[4px] relative shrink-0 w-0" data-name="Container" />;
}

function Button37() {
  return (
    <div className="col-1 content-stretch flex flex-col gap-[2px] items-center justify-self-stretch relative rounded-[8px] row-6 self-stretch shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[#111827] text-[12px] text-center whitespace-nowrap">31</p>
      <Container73 />
    </div>
  );
}

function Container74() {
  return <div className="col-2 justify-self-stretch relative row-6 self-stretch shrink-0" data-name="Container" />;
}

function Container75() {
  return <div className="col-3 justify-self-stretch relative row-6 self-stretch shrink-0" data-name="Container" />;
}

function Container76() {
  return <div className="col-4 justify-self-stretch relative row-6 self-stretch shrink-0" data-name="Container" />;
}

function Container77() {
  return <div className="col-5 justify-self-stretch relative row-6 self-stretch shrink-0" data-name="Container" />;
}

function Container78() {
  return <div className="col-6 justify-self-stretch relative row-6 self-stretch shrink-0" data-name="Container" />;
}

function Container79() {
  return <div className="col-7 justify-self-stretch relative row-6 self-stretch shrink-0" data-name="Container" />;
}

function Container37() {
  return (
    <div className="gap-y-[4px] grid grid-cols-[_______45.08px_45.10px_45.08px_45.10px_45.08px_45.10px_45.10px] grid-rows-[______23.98px_23.98px_23.98px_23.98px_23.98px_23.98px] h-[164px] relative shrink-0 w-full" data-name="Container">
      <Container38 />
      <Container39 />
      <Container40 />
      <Container41 />
      <Container42 />
      <Button7 />
      <Button8 />
      <Button9 />
      <Button10 />
      <Button11 />
      <Button12 />
      <Button13 />
      <Button14 />
      <Button15 />
      <Button16 />
      <Button17 />
      <Button18 />
      <Button19 />
      <Button20 />
      <Button21 />
      <Button22 />
      <Button23 />
      <Button24 />
      <Button25 />
      <Button26 />
      <Button27 />
      <Button28 />
      <Button29 />
      <Button30 />
      <Button31 />
      <Button32 />
      <Button33 />
      <Button34 />
      <Button35 />
      <Button36 />
      <Button37 />
      <Container74 />
      <Container75 />
      <Container76 />
      <Container77 />
      <Container78 />
      <Container79 />
    </div>
  );
}

function ContainerMargin1() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[4px] relative shrink-0 w-full" data-name="Container:margin">
      <Container37 />
    </div>
  );
}

function GrowthCalendar() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[316px]" data-name="GrowthCalendar">
      <Container19 />
      <ContainerMargin />
      <ContainerMargin1 />
    </div>
  );
}

function Paragraph10() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">8月29日 · 周六</p>
    </div>
  );
}

function Container83() {
  return <div className="bg-[#4f7ef5] relative rounded-[39856500px] shrink-0 size-[8px]" data-name="Container" />;
}

function Container82() {
  return (
    <div className="bg-[rgba(79,126,245,0.09)] border-[1.188px] border-[rgba(79,126,245,0.25)] border-solid content-stretch flex items-center justify-center relative rounded-[39856500px] shrink-0 size-[28px]" data-name="Container">
      <Container83 />
    </div>
  );
}

function Container81() {
  return (
    <div className="content-stretch flex flex-col h-[80.624px] items-start pt-[2px] relative shrink-0 w-[28px]" data-name="Container">
      <Container82 />
    </div>
  );
}

function Text13() {
  return (
    <div className="bg-[rgba(79,126,245,0.08)] content-stretch flex flex-col items-start px-[5px] py-px relative rounded-[4px] shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[13.5px] not-italic relative shrink-0 text-[#4f7ef5] text-[9px] whitespace-nowrap">分析</p>
    </div>
  );
}

function Text14() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[15px] not-italic relative shrink-0 text-[#34c759] text-[10px] whitespace-nowrap">+8%</p>
    </div>
  );
}

function Container85() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0 w-full" data-name="Container">
      <Text13 />
      <Text14 />
    </div>
  );
}

function Paragraph11() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start pt-[2px] relative shrink-0 w-[249.624px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[18px] not-italic relative shrink-0 text-[#111827] text-[13px] whitespace-nowrap">完成职业分析</p>
    </div>
  );
}

function Paragraph12() {
  return (
    <div className="content-stretch flex flex-col h-[18px] items-start pt-px relative shrink-0 w-[249.624px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">AI 产品经理</p>
    </div>
  );
}

function Text15() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[15px] not-italic relative shrink-0 text-[#4f7ef5] text-[10px] whitespace-nowrap">86%</p>
    </div>
  );
}

function Container87() {
  return (
    <div className="absolute bg-[rgba(79,126,245,0.07)] border-[1.188px] border-[rgba(79,126,245,0.14)] border-solid content-stretch flex items-center left-[-0.21px] px-[8px] py-[2px] rounded-[39856500px] top-[6.42px]" data-name="Container">
      <Text15 />
    </div>
  );
}

function Container86() {
  return (
    <div className="h-[27.453px] relative shrink-0 w-full" data-name="Container">
      <Container87 />
    </div>
  );
}

function Container84() {
  return (
    <div className="content-stretch flex flex-[249_0_0] flex-col h-full items-start min-w-px relative" data-name="Container">
      <Container85 />
      <Paragraph11 />
      <Paragraph12 />
      <Container86 />
    </div>
  );
}

function Container80() {
  return (
    <div className="absolute bg-[rgba(255,255,255,0.65)] border-[1.188px] border-[rgba(255,255,255,0.55)] border-solid content-stretch flex gap-[12px] h-[107px] items-start left-0 p-[12px] rounded-[16px] top-0 w-[316px]" data-name="Container">
      <Container81 />
      <Container84 />
    </div>
  );
}

function GrowthEventCard() {
  return (
    <div className="h-[107px] relative shrink-0 w-full" data-name="GrowthEventCard">
      <Container80 />
    </div>
  );
}

function ContainerMargin2() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[8px] relative shrink-0 w-full" data-name="Container:margin">
      <GrowthEventCard />
    </div>
  );
}

function ProfilePage1() {
  return (
    <div className="border-[rgba(229,231,235,0.7)] border-solid border-t-[1.188px] content-stretch flex flex-col items-start pt-[12px] relative shrink-0 w-[316px]" data-name="ProfilePage">
      <Paragraph10 />
      <ContainerMargin2 />
    </div>
  );
}

function ProfilePageMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0" data-name="ProfilePage:margin">
      <ProfilePage1 />
    </div>
  );
}

function Card() {
  return (
    <div className="backdrop-blur-[24px] bg-[rgba(255,255,255,0.68)] border-[1.188px] border-[rgba(255,255,255,0.55)] border-solid content-stretch flex flex-col items-start p-[16px] relative rounded-[24px] shadow-[0px_8px_32px_0px_rgba(79,126,245,0.08)] shrink-0 w-full" data-name="Card">
      <GrowthCalendar />
      <ProfilePageMargin />
    </div>
  );
}

function CardMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0 w-full" data-name="Card:margin">
      <Card />
    </div>
  );
}

function Container17() {
  return (
    <div className="content-stretch flex flex-col h-[487px] items-start pt-[20px] px-[20px] relative shrink-0 w-[390px]" data-name="Container">
      <Container18 />
      <CardMargin />
    </div>
  );
}

function Frame7() {
  return (
    <div className="content-stretch flex flex-col h-[1086px] items-start relative shrink-0 w-full">
      <AvatarSection />
      <UserInfoContainer />
      <FilterTabs />
      <Container7 />
      <Container17 />
    </div>
  );
}

function Icon8() {
  return (
    <div className="relative shrink-0 size-[19.989px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="19.9887" preserveAspectRatio="none" viewBox="0 0 19.9887 19.9887" width="19.9887">
        <g clipPath="url(#clip0_0_26)" id="Icon">
          <path d={svgPaths.pda84800} id="Vector" stroke="#34C759" strokeLinejoin="round" strokeWidth="1.41587" />
          <path d={svgPaths.p3a04f980} id="Vector_2" stroke="#34C759" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.41587" />
          <path d="M6.6629 10.8272H13.3258" id="Vector_3" stroke="#34C759" strokeLinecap="round" strokeWidth="1.24929" />
          <path d="M6.6629 14.1587H13.3258" id="Vector_4" stroke="#34C759" strokeLinecap="round" strokeWidth="1.24929" />
        </g>
        <defs>
          <clipPath id="clip0_0_26">
            <rect fill="white" height="19.9887" width="19.9887" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container89() {
  return (
    <div className="bg-[rgba(52,199,89,0.1)] content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[40px]" data-name="Container">
      <Icon8 />
    </div>
  );
}

function Paragraph13() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">我的简历</p>
    </div>
  );
}

function Paragraph14() {
  return (
    <div className="content-stretch flex flex-col h-[19px] items-start pt-[2px] relative shrink-0 w-[206px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">Resume V3 · 2026.08.27</p>
    </div>
  );
}

function Container90() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[206px]" data-name="Container">
      <Paragraph13 />
      <Paragraph14 />
    </div>
  );
}

function Text16() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[15px] not-italic relative shrink-0 text-[#34c759] text-[10px] text-right whitespace-nowrap">最新版</p>
    </div>
  );
}

function Container93() {
  return (
    <div className="absolute bg-[rgba(52,199,89,0.12)] content-stretch flex items-center left-0 px-[8px] py-[2px] rounded-[39856500px] top-[5.08px]" data-name="Container">
      <Text16 />
    </div>
  );
}

function Container92() {
  return (
    <div className="h-[26.05px] relative shrink-0 w-full" data-name="Container">
      <Container93 />
    </div>
  );
}

function Icon9() {
  return (
    <div className="relative shrink-0 size-[13.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="13.9939" preserveAspectRatio="none" viewBox="0 0 13.9939 13.9939" width="13.9939">
        <g id="Icon">
          <path d={svgPaths.peaf3e80} id="Vector" stroke="#6B7280" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.16616" />
        </g>
      </svg>
    </div>
  );
}

function IconMargin() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-full" data-name="Icon:margin">
      <Icon9 />
    </div>
  );
}

function Container91() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[46px]" data-name="Container">
      <Container92 />
      <IconMargin />
    </div>
  );
}

function ProfilePage2() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0" data-name="ProfilePage">
      <Container89 />
      <Container90 />
      <Container91 />
    </div>
  );
}

function Card1() {
  return (
    <div className="absolute backdrop-blur-[24px] bg-[rgba(255,255,255,0.68)] border-[1.188px] border-[rgba(255,255,255,0.55)] border-solid content-stretch flex flex-col items-start left-0 p-[16px] rounded-[24px] shadow-[0px_8px_32px_0px_rgba(79,126,245,0.08)] top-0" data-name="Card">
      <ProfilePage2 />
    </div>
  );
}

function Button38() {
  return (
    <div className="absolute h-[74px] left-[20px] rounded-[32px] top-0 w-[350px]" data-name="Button">
      <Card1 />
    </div>
  );
}

function Container88() {
  return (
    <div className="h-[74px] relative shrink-0 w-full" data-name="Container">
      <Button38 />
    </div>
  );
}

function ContainerMargin3() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0 w-full" data-name="Container:margin">
      <Container88 />
    </div>
  );
}

function Icon10() {
  return (
    <div className="relative shrink-0 size-[19.989px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="19.9887" preserveAspectRatio="none" viewBox="0 0 19.9887 19.9887" width="19.9887">
        <g id="Icon">
          <path d={svgPaths.p1f86000} fill="#4F7EF5" id="Vector" />
          <path d={svgPaths.p3e29b00} fill="#4F7EF5" fillOpacity="0.6" id="Vector_2" />
          <path d={svgPaths.p32b57c00} fill="#4F7EF5" fillOpacity="0.3" id="Vector_3" />
        </g>
      </svg>
    </div>
  );
}

function Container95() {
  return (
    <div className="bg-[rgba(79,126,245,0.09)] content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[40px]" data-name="Container">
      <Icon10 />
    </div>
  );
}

function Paragraph15() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">历史分析</p>
    </div>
  );
}

function Paragraph16() {
  return (
    <div className="content-stretch flex flex-col h-[19px] items-start pt-[2px] relative shrink-0 w-[238.006px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">最近分析 2026.08.29 · 最高 86%</p>
    </div>
  );
}

function Container96() {
  return (
    <div className="content-stretch flex flex-[238_0_0] flex-col items-start min-w-px relative" data-name="Container">
      <Paragraph15 />
      <Paragraph16 />
    </div>
  );
}

function Icon11() {
  return (
    <div className="relative shrink-0 size-[13.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="13.9939" preserveAspectRatio="none" viewBox="0 0 13.9939 13.9939" width="13.9939">
        <g id="Icon">
          <path d={svgPaths.peaf3e80} id="Vector" stroke="#6B7280" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.16616" />
        </g>
      </svg>
    </div>
  );
}

function ProfilePage3() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-[316px]" data-name="ProfilePage">
      <Container95 />
      <Container96 />
      <Icon11 />
    </div>
  );
}

function Card2() {
  return (
    <div className="absolute backdrop-blur-[24px] bg-[rgba(255,255,255,0.68)] border-[1.188px] border-[rgba(255,255,255,0.55)] border-solid content-stretch flex flex-col items-start left-0 p-[16px] rounded-[24px] shadow-[0px_8px_32px_0px_rgba(79,126,245,0.08)] top-0" data-name="Card">
      <ProfilePage3 />
    </div>
  );
}

function Button39() {
  return (
    <div className="absolute h-[74px] left-[20px] top-0 w-[350px]" data-name="Button">
      <Card2 />
    </div>
  );
}

function Container94() {
  return (
    <div className="h-[74px] relative shrink-0 w-full" data-name="Container">
      <Button39 />
    </div>
  );
}

function ContainerMargin4() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0 w-full" data-name="Container:margin">
      <Container94 />
    </div>
  );
}

function Icon12() {
  return (
    <div className="relative shrink-0 size-[19.989px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="19.9887" preserveAspectRatio="none" viewBox="0 0 19.9887 19.9887" width="19.9887">
        <g clipPath="url(#clip0_0_44)" id="Icon">
          <path d={svgPaths.p1f28d700} id="Vector" stroke="#6B7280" strokeWidth="1.49915" />
          <path d={svgPaths.pf378c00} id="Vector_2" stroke="#6B7280" strokeWidth="1.49915" />
        </g>
        <defs>
          <clipPath id="clip0_0_44">
            <rect fill="white" height="19.9887" width="19.9887" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container98() {
  return (
    <div className="bg-[rgba(107,114,128,0.08)] content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[40px]" data-name="Container">
      <Icon12 />
    </div>
  );
}

function Paragraph17() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">设置</p>
    </div>
  );
}

function Paragraph18() {
  return (
    <div className="content-stretch flex flex-col h-[19px] items-start pt-[2px] relative shrink-0 w-[238.006px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">账户 · 隐私 · 通知 · 关于</p>
    </div>
  );
}

function Container99() {
  return (
    <div className="content-stretch flex flex-[238_0_0] flex-col items-start min-w-px relative" data-name="Container">
      <Paragraph17 />
      <Paragraph18 />
    </div>
  );
}

function Icon13() {
  return (
    <div className="relative shrink-0 size-[13.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="13.9939" preserveAspectRatio="none" viewBox="0 0 13.9939 13.9939" width="13.9939">
        <g id="Icon">
          <path d={svgPaths.peaf3e80} id="Vector" stroke="#6B7280" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.16616" />
        </g>
      </svg>
    </div>
  );
}

function ProfilePage4() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-[316px]" data-name="ProfilePage">
      <Container98 />
      <Container99 />
      <Icon13 />
    </div>
  );
}

function Card3() {
  return (
    <div className="absolute backdrop-blur-[24px] bg-[rgba(255,255,255,0.68)] border-[1.188px] border-[rgba(255,255,255,0.55)] border-solid content-stretch flex flex-col items-start left-0 p-[16px] rounded-[24px] shadow-[0px_8px_32px_0px_rgba(79,126,245,0.08)] top-0" data-name="Card">
      <ProfilePage4 />
    </div>
  );
}

function Button40() {
  return (
    <div className="absolute h-[74px] left-[20px] top-0 w-[350px]" data-name="Button">
      <Card3 />
    </div>
  );
}

function Container97() {
  return (
    <div className="h-[74px] relative shrink-0 w-full" data-name="Container">
      <Button40 />
    </div>
  );
}

function ContainerMargin5() {
  return (
    <div className="content-stretch flex flex-col items-start py-[12px] relative shrink-0 w-full" data-name="Container:margin">
      <Container97 />
    </div>
  );
}

function ProfilePage() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[24px] relative shrink-0 w-full" data-name="ProfilePage">
      <Frame7 />
      <ContainerMargin3 />
      <ContainerMargin4 />
      <ContainerMargin5 />
    </div>
  );
}

function Container4() {
  return (
    <div className="content-stretch flex flex-col h-[811px] items-start pb-[96px] relative shrink-0 w-[390px]" data-name="Container">
      <ProfilePage />
    </div>
  );
}

function Container3() {
  return (
    <div className="absolute content-stretch flex flex-col h-[809.998px] items-start left-0 right-0 top-[34px]" data-name="Container">
      <Container4 />
    </div>
  );
}

function Container102() {
  return <div className="absolute bg-[rgba(255,255,255,0.18)] border-[1.188px] border-[rgba(255,255,255,0.35)] border-solid h-[64.328px] left-[-0.98px] rounded-[31px] top-[-0.98px] w-[236.282px]" data-name="Container" />;
}

function Container104() {
  return (
    <div className="absolute h-[50px] left-[155.18px] pointer-events-none rounded-[22px] top-[6.18px] w-[71.993px]" data-name="Container">
      <div aria-hidden className="absolute backdrop-blur-[6px] bg-[rgba(255,255,255,0.5)] inset-0 rounded-[22px]" />
      <div aria-hidden className="absolute border-[1.188px] border-[rgba(255,255,255,0.4)] border-solid inset-0 rounded-[22px] shadow-[0px_1px_6px_0px_rgba(0,0,0,0.07)]" />
      <div className="absolute inset-0 rounded-[inherit] shadow-[inset_0px_1px_0px_0px_rgba(255,255,255,0.55)]" />
    </div>
  );
}

function IconHome() {
  return (
    <div className="relative shrink-0 size-[21.993px]" data-name="IconHome">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.9931" preserveAspectRatio="none" viewBox="0 0 21.9931 21.9931" width="21.9931">
        <g id="IconHome">
          <path d={svgPaths.p38475f80} id="Vector" stroke="#7B7979" strokeLinejoin="round" strokeWidth="1.55784" />
        </g>
      </svg>
    </div>
  );
}

function Button41() {
  return (
    <div className="absolute content-stretch flex h-[50px] items-center justify-center left-[7.18px] rounded-[22px] top-[6.18px] w-[71.993px]" data-name="Button">
      <IconHome />
    </div>
  );
}

function IconChart() {
  return (
    <div className="relative shrink-0 size-[21.993px]" data-name="IconChart">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.9931" preserveAspectRatio="none" viewBox="0 0 21.9931 21.9931" width="21.9931">
        <g id="IconChart">
          <path d={svgPaths.p1709580} fill="#7B7979" id="Vector" />
          <path d={svgPaths.p27e47d00} fill="#7B7979" id="Vector_2" />
          <path d={svgPaths.pa8d6600} fill="#7B7979" id="Vector_3" />
        </g>
      </svg>
    </div>
  );
}

function Button42() {
  return (
    <div className="absolute content-stretch flex h-[50px] items-center justify-center left-[81.16px] rounded-[22px] top-[6.18px] w-[71.993px]" data-name="Button">
      <IconChart />
    </div>
  );
}

function IconUser() {
  return (
    <div className="relative shrink-0 size-[21.993px]" data-name="IconUser">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.9931" preserveAspectRatio="none" viewBox="0 0 21.9931 21.9931" width="21.9931">
        <g id="IconUser">
          <path d={svgPaths.p2856bc80} fill="url(#paint0_linear_0_4)" id="Vector" />
          <path d={svgPaths.p2fa6d900} id="Vector_2" stroke="url(#paint1_linear_0_4)" strokeLinecap="round" strokeWidth="1.55784" />
        </g>
        <defs>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint0_linear_0_4" x1="3.66552" x2="18.3276" y1="3.66552" y2="18.3276">
            <stop stopColor="#4F7EF5" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint1_linear_0_4" x1="3.66552" x2="18.3276" y1="3.66552" y2="18.3276">
            <stop stopColor="#4F7EF5" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  );
}

function Button43() {
  return (
    <div className="absolute content-stretch flex h-[50px] items-center justify-center left-[155.14px] rounded-[22px] top-[6.18px] w-[72px]" data-name="Button">
      <IconUser />
    </div>
  );
}

function Container103() {
  return (
    <div className="absolute h-[62.36px] left-0 rounded-[30px] top-0 w-[234.315px]" data-name="Container">
      <div aria-hidden className="absolute backdrop-blur-[10px] bg-[rgba(255,255,255,0.04)] inset-0 pointer-events-none rounded-[30px]" />
      <div aria-hidden className="absolute border-[1.188px] border-[rgba(255,255,255,0.3)] border-solid inset-0 pointer-events-none rounded-[30px] shadow-[0px_6px_24px_0px_rgba(0,0,0,0.08),0px_1px_4px_0px_rgba(0,0,0,0.04)]" />
      <Container104 />
      <Button41 />
      <Button42 />
      <Button43 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.62),inset_0px_-1px_0px_0px_rgba(255,255,255,0.12),inset_1px_0px_0px_0px_rgba(255,255,255,0.18),inset_-1px_0px_0px_0px_rgba(255,255,255,0.1)]" />
    </div>
  );
}

function Container101() {
  return (
    <div className="h-[62.36px] relative rounded-[30px] shrink-0 w-[234.315px]" data-name="Container">
      <Container102 />
      <Container103 />
    </div>
  );
}

function Text17() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Plus_Jakarta_Sans:Regular','Noto_Sans:Regular','Noto_Sans_Math:Regular','Noto_Sans_Symbols:Regular','Noto_Sans_Symbols2:Regular',sans-serif] font-normal leading-[24px] relative shrink-0 text-[22px] text-center text-white whitespace-nowrap">✦</p>
    </div>
  );
}

function Text18() {
  return (
    <div className="content-stretch flex flex-col items-center pt-[2px] relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[13.5px] not-italic relative shrink-0 text-[9px] text-[rgba(255,255,255,0.92)] text-center whitespace-nowrap">AI</p>
    </div>
  );
}

function Button44() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center opacity-88 relative rounded-[99px] shrink-0 size-[62px]" data-name="Button">
      <div aria-hidden className="absolute backdrop-blur-[10px] inset-0 pointer-events-none rounded-[99px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(79, 126, 245, 0.72) 0%, rgba(167, 123, 230, 0.72) 100%)" }} />
      <div aria-hidden className="absolute border-[1.188px] border-[rgba(255,255,255,0.42)] border-solid inset-0 pointer-events-none rounded-[99px] shadow-[0px_8px_24px_0px_rgba(79,126,245,0.3),0px_2px_6px_0px_rgba(0,0,0,0.06)]" />
      <Text17 />
      <Text18 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.5),inset_0px_-1px_0px_0px_rgba(79,126,245,0.2)]" />
    </div>
  );
}

function Container100() {
  return (
    <div className="absolute content-stretch flex gap-[10px] h-[90.36px] items-center justify-center left-0 pb-[20px] pt-[8px] right-0 top-[844px]" data-name="Container">
      <Container101 />
      <Button44 />
    </div>
  );
}

function Container() {
  return (
    <div className="absolute h-[844px] left-[5.74px] top-[15.71px] w-[389.993px]" style={{ backgroundImage: "linear-gradient(110.29421913688485deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container1 />
      <Container3 />
      <Container100 />
    </div>
  );
}

function App() {
  return (
    <div className="absolute bg-[#d2def0] h-[875.42px] left-0 top-0 w-[401.482px]" data-name="App">
      <Container />
    </div>
  );
}

export default function CareerlyAppInterfaceDesignCopy() {
  return (
    <div className="bg-white relative size-full" data-name="Careerly App Interface Design (Copy)">
      <App />
    </div>
  );
}