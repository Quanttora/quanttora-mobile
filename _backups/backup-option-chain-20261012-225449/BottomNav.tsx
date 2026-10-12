import React from 'react';
import { Home, Compass, Cpu, GraduationCap, BookMarked, BarChart3, Gamepad2 } from 'lucide-react';
import { NavigationTab } from '../types';

interface BottomNavProps {
  activeTab: NavigationTab;
  onSelectTab: (tab: NavigationTab) => void;
  decisionBadgeCount?: number;
}

export const BottomNav: React.FC<BottomNavProps> = ({
  activeTab,
  onSelectTab,
  decisionBadgeCount = 0,
}) => {
  const tabs: { id: NavigationTab; label: string; icon: React.FC<{ className?: string }> }[] = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'discover', label: 'Discover', icon: Compass },
    { id: 'decision', label: 'Decision', icon: Cpu },
    { id: 'academy', label: 'Academy', icon: GraduationCap },
    { id: 'journal', label: 'Journal', icon: BookMarked },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 bg-white/95 backdrop-blur-md border-t border-slate-200 shadow-lg md:max-w-md md:mx-auto md:bottom-3 md:rounded-2xl md:border">
      <div className="flex items-center justify-around px-2 py-1.5 sm:py-2">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;

          return (
            <button
              key={tab.id}
              onClick={() => onSelectTab(tab.id)}
              className={`relative flex flex-col items-center justify-center py-1 px-3 sm:px-4 rounded-xl transition-all ${
                isActive
                  ? 'text-indigo-600 font-semibold'
                  : 'text-slate-500 hover:text-slate-800 font-medium'
              }`}
            >
              {/* Highlight background pill for active */}
              {isActive && (
                <span className="absolute inset-0 bg-indigo-50/90 rounded-xl -z-10" />
              )}

              <div className="relative">
                <Icon className={`w-5 h-5 transition-transform ${isActive ? 'scale-110' : ''}`} />
                {tab.id === 'decision' && decisionBadgeCount > 0 && (
                  <span className="absolute -top-1 -right-2.5 w-4 h-4 bg-emerald-500 text-white rounded-full text-[9px] font-bold flex items-center justify-center">
                    {decisionBadgeCount}
                  </span>
                )}
              </div>

              <span className={`text-[10.5px] mt-1 tracking-tight ${isActive ? 'font-bold text-indigo-700' : 'text-slate-600'}`}>
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
